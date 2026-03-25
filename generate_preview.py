#!/usr/bin/env python3
"""
generate_previews.py
====================
Scanne un projet Swift/Xcode, trouve tous les #Preview {},
résout récursivement les dépendances (class, struct, enum, protocol),
et génère des fichiers autonomes dans PreviewRenders/ compatibles
avec swiftui-render (chaque fichier contient struct Preview: View).

Usage:
    python3 generate_previews.py [chemin_du_projet]

Si aucun chemin n'est donné, utilise le dossier courant.
"""

import os
import re
import sys
from pathlib import Path
from dataclasses import dataclass, field


# ── Configuration ──────────────────────────────────────────────

# Dossiers à ignorer pendant le scan
IGNORED_DIRS = {
    ".build", "build", "DerivedData", "Pods", ".git",
    "PreviewRenders", "Packages", ".swiftpm", "node_modules",
}

# Imports système qu'on n'a pas besoin de résoudre
SYSTEM_MODULES = {
    "SwiftUI", "Foundation", "UIKit", "Combine", "SwiftData",
    "CoreData", "MapKit", "Charts", "PhotosUI", "AVFoundation",
    "CoreLocation", "CoreImage", "WebKit", "StoreKit",
    "WidgetKit", "AppIntents", "Observation",
}

OUTPUT_DIR = "PreviewRenders"


# ── Modèles de données ────────────────────────────────────────

@dataclass
class TypeDefinition:
    """Représente un type Swift trouvé dans le projet."""
    name: str               # Nom du type (ex: "UserViewModel")
    kind: str               # "struct", "class", "enum", "protocol", "actor"
    file_path: str          # Chemin du fichier source
    source_code: str        # Code source complet du type
    start_line: int         # Ligne de début dans le fichier
    dependencies: set = field(default_factory=set)  # Types référencés


@dataclass
class PreviewBlock:
    """Représente un bloc #Preview trouvé dans le projet."""
    file_path: str          # Fichier contenant le #Preview
    file_name: str          # Nom du fichier (sans extension)
    source_code: str        # Code du bloc #Preview
    parent_view: str | None # Vue principale si détectable
    imports: list = field(default_factory=list)  # Imports du fichier


# ── Parsing Swift ──────────────────────────────────────────────

def find_swift_files(project_path: str) -> list[str]:
    """Trouve tous les fichiers .swift du projet."""
    swift_files = []
    for root, dirs, files in os.walk(project_path):
        # Filtrer les dossiers ignorés
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS]
        for f in files:
            if f.endswith(".swift"):
                swift_files.append(os.path.join(root, f))
    return swift_files


def extract_balanced_braces(text: str, start_pos: int) -> str | None:
    """
    À partir de la position de la première '{', extrait tout le bloc
    en respectant l'imbrication des accolades.
    """
    if start_pos >= len(text) or text[start_pos] != '{':
        return None

    depth = 0
    i = start_pos
    in_string = False
    in_line_comment = False
    in_block_comment = False
    escape_next = False

    while i < len(text):
        ch = text[i]

        if escape_next:
            escape_next = False
            i += 1
            continue

        if in_line_comment:
            if ch == '\n':
                in_line_comment = False
            i += 1
            continue

        if in_block_comment:
            if ch == '*' and i + 1 < len(text) and text[i + 1] == '/':
                in_block_comment = False
                i += 2
                continue
            i += 1
            continue

        if ch == '\\' and in_string:
            escape_next = True
            i += 1
            continue

        if ch == '"' and not in_string:
            # Vérifier les multiline strings """
            if text[i:i+3] == '"""':
                # Trouver le prochain """
                end = text.find('"""', i + 3)
                if end != -1:
                    i = end + 3
                    continue
            in_string = True
            i += 1
            continue

        if ch == '"' and in_string:
            in_string = False
            i += 1
            continue

        if not in_string:
            if ch == '/' and i + 1 < len(text):
                if text[i + 1] == '/':
                    in_line_comment = True
                    i += 2
                    continue
                elif text[i + 1] == '*':
                    in_block_comment = True
                    i += 2
                    continue

            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    return text[start_pos:i + 1]

        i += 1

    return None


def parse_type_definitions(file_path: str, source: str) -> list[TypeDefinition]:
    """
    Parse un fichier Swift et extrait toutes les définitions de types
    (struct, class, enum, protocol, actor) avec leur code source complet.
    """
    types = []

    # Pattern pour trouver les déclarations de types au top-level
    # Gère : access modifiers, attributs (@Observable, etc.), generics
    pattern = re.compile(
        r'^[ \t]*'                                          # Indentation
        r'(?:@\w+(?:\([^)]*\))?\s+)*'                      # Attributs (@Observable, @MainActor, etc.)
        r'(?:(?:public|private|internal|fileprivate|open)\s+)?'  # Access modifier
        r'(?:final\s+)?'                                    # final
        r'(struct|class|enum|protocol|actor)\s+'             # Mot-clé du type
        r'(\w+)',                                            # Nom du type
        re.MULTILINE
    )

    for match in pattern.finditer(source):
        kind = match.group(1)
        name = match.group(2)

        # Trouver l'accolade ouvrante
        after_match = source[match.end():]
        brace_offset = after_match.find('{')
        if brace_offset == -1:
            continue

        brace_pos = match.end() + brace_offset

        # Extraire le bloc complet
        block = extract_balanced_braces(source, brace_pos)
        if block is None:
            continue

        # Le code complet = de la déclaration jusqu'à la fin du bloc
        # On inclut aussi les attributs avant la déclaration
        decl_start = match.start()
        
        # Remonter pour capturer les attributs sur les lignes précédentes
        lines = source[:decl_start].split('\n')
        attr_lines = []
        for line in reversed(lines):
            stripped = line.strip()
            if stripped.startswith('@') or stripped.startswith('//'):
                attr_lines.insert(0, line)
            else:
                break
        
        if attr_lines:
            attr_text = '\n'.join(attr_lines) + '\n'
            full_source = attr_text + source[decl_start:brace_pos] + block
        else:
            full_source = source[decl_start:brace_pos] + block

        start_line = source[:decl_start].count('\n') + 1

        types.append(TypeDefinition(
            name=name,
            kind=kind,
            file_path=file_path,
            source_code=full_source,
            start_line=start_line,
        ))

    return types


def parse_preview_blocks(file_path: str, source: str) -> list[PreviewBlock]:
    """
    Trouve tous les blocs #Preview dans un fichier.
    """
    previews = []
    file_name = Path(file_path).stem

    # Extraire les imports du fichier
    imports = re.findall(r'^import\s+(\w+)', source, re.MULTILINE)

    # Pattern pour #Preview { ... } ou #Preview("name") { ... }
    pattern = re.compile(r'#Preview(?:\s*\([^)]*\))?\s*\{')

    for match in pattern.finditer(source):
        brace_pos = source.rfind('{', match.start(), match.end() + 1)
        if brace_pos == -1:
            brace_pos = match.end() - 1

        block = extract_balanced_braces(source, brace_pos)
        if block is None:
            continue

        preview_source = source[match.start():brace_pos] + block

        # Essayer de détecter la vue principale dans le preview
        parent_view = None
        view_pattern = re.compile(r'\b([A-Z]\w+)\s*\(')
        view_matches = view_pattern.findall(block)
        # Filtrer les types SwiftUI connus
        swiftui_types = {
            "VStack", "HStack", "ZStack", "Text", "Image", "Button",
            "NavigationStack", "NavigationView", "List", "Form",
            "ScrollView", "LazyVGrid", "LazyHGrid", "Section",
            "Group", "ForEach", "TabView", "NavigationSplitView",
            "Spacer", "Divider", "Color", "Circle", "Rectangle",
            "RoundedRectangle", "Capsule", "Toggle", "TextField",
            "Picker", "Slider", "Stepper", "DatePicker", "ProgressView",
            "Label", "Link", "Menu", "Sheet", "Alert",
            "UUID", "Date", "URL", "String", "Int", "Double", "Bool",
            "CGFloat", "CGSize", "CGPoint", "Font", "EdgeInsets",
        }
        for v in view_matches:
            if v not in swiftui_types:
                parent_view = v
                break

        previews.append(PreviewBlock(
            file_path=file_path,
            file_name=file_name,
            source_code=preview_source,
            parent_view=parent_view,
            imports=imports,
        ))

    return previews


def find_type_references(source_code: str, known_types: set[str]) -> set[str]:
    """
    Trouve tous les noms de types connus référencés dans un bloc de code.
    """
    refs = set()
    for type_name in known_types:
        # Chercher le type utilisé comme : nom de type, dans des generics,
        # comme annotation, dans des inits, etc.
        patterns = [
            rf'\b{re.escape(type_name)}\s*\(',          # Init: MyType(...)
            rf'\b{re.escape(type_name)}\s*\.',          # Static: MyType.something
            rf':\s*{re.escape(type_name)}\b',           # Annotation: var x: MyType
            rf':\s*\[{re.escape(type_name)}\]',         # Array: [MyType]
            rf'<{re.escape(type_name)}>',               # Generic: Array<MyType>
            rf'\b{re.escape(type_name)}\s*\?',          # Optional: MyType?
            rf'\bis\s+{re.escape(type_name)}\b',        # Type check: is MyType
            rf'\bas\s+{re.escape(type_name)}\b',        # Cast: as MyType
            rf'\b{re.escape(type_name)}\s*:',           # Conformance: MyType: Protocol
            rf'@ObservedObject\s+var\s+\w+\s*:\s*{re.escape(type_name)}',
            rf'@StateObject\s+var\s+\w+\s*:\s*{re.escape(type_name)}',
            rf'@EnvironmentObject\s+var\s+\w+\s*:\s*{re.escape(type_name)}',
        ]
        for p in patterns:
            if re.search(p, source_code):
                refs.add(type_name)
                break
    return refs


def resolve_dependencies(
    target_types: set[str],
    all_types: dict[str, TypeDefinition],
    resolved: set[str] | None = None,
    depth: int = 0
) -> list[TypeDefinition]:
    """
    Résout récursivement toutes les dépendances d'un ensemble de types.
    Retourne une liste ordonnée (dépendances d'abord, types principaux ensuite).
    """
    if resolved is None:
        resolved = set()

    if depth > 20:  # Protection contre les cycles
        return []

    result = []
    known_names = set(all_types.keys())

    for type_name in target_types:
        if type_name in resolved:
            continue
        if type_name not in all_types:
            continue

        resolved.add(type_name)
        type_def = all_types[type_name]

        # Trouver les types référencés dans ce type
        sub_deps = find_type_references(type_def.source_code, known_names - resolved)

        # Résoudre récursivement
        if sub_deps:
            sub_result = resolve_dependencies(sub_deps, all_types, resolved, depth + 1)
            result.extend(sub_result)

        result.append(type_def)

    return result


def extract_file_level_types(file_path: str, source: str, all_types: dict[str, TypeDefinition]) -> list[TypeDefinition]:
    """
    Extrait les types définis dans le même fichier qu'un #Preview.
    Utile car le preview dépend souvent des types du même fichier.
    """
    types = []
    for td in all_types.values():
        if td.file_path == file_path:
            types.append(td)
    return types


# ── Génération des fichiers de preview ─────────────────────────

def generate_preview_file(
    preview: PreviewBlock,
    all_types: dict[str, TypeDefinition],
    all_type_defs_in_same_file: list[TypeDefinition],
) -> str:
    """
    Génère un fichier Swift autonome pour un #Preview donné.
    """
    lines = []

    # Header
    lines.append(f"// Auto-generated by generate_previews.py")
    lines.append(f"// Source: {preview.file_path}")
    lines.append(f"// Ne pas modifier — ce fichier est regénéré automatiquement.")
    lines.append("")

    # Imports (toujours SwiftUI, plus les autres du fichier original)
    used_imports = {"SwiftUI"}
    for imp in preview.imports:
        if imp in SYSTEM_MODULES:
            used_imports.add(imp)
    for imp in sorted(used_imports):
        lines.append(f"import {imp}")
    lines.append("")

    # 1. Collecter les types du même fichier
    same_file_type_names = {td.name for td in all_type_defs_in_same_file}

    # 2. Trouver les dépendances depuis le preview + les types du même fichier
    known_names = set(all_types.keys())
    
    # Types référencés dans le code du preview
    preview_refs = find_type_references(preview.source_code, known_names)
    
    # Types référencés dans les types du même fichier
    all_needed = set(same_file_type_names) | preview_refs
    
    # Résoudre récursivement
    resolved_types = resolve_dependencies(all_needed, all_types)

    # 3. Écrire les types (dédupliqués, dans l'ordre de résolution)
    seen = set()
    for td in resolved_types:
        if td.name not in seen:
            seen.add(td.name)
            lines.append(f"// ── {td.kind} {td.name} (from {Path(td.file_path).name}) ──")
            lines.append("")
            lines.append(td.source_code)
            lines.append("")

    # 4. Écrire le bloc Preview transformé en struct Preview: View
    lines.append("// ── Preview ──")
    lines.append("")

    # Transformer #Preview { ... } en struct Preview: View { var body: some View { ... } }
    # Extraire le contenu du bloc #Preview
    preview_content = preview.source_code

    # Extraire le corps du #Preview { ... }
    brace_match = re.search(r'\{', preview_content)
    if brace_match:
        inner_block = extract_balanced_braces(preview_content, brace_match.start())
        if inner_block:
            # Retirer les accolades extérieures
            inner = inner_block[1:-1].strip()
            lines.append("struct Preview: View {")
            lines.append("    var body: some View {")
            # Indenter le contenu
            for line in inner.split('\n'):
                lines.append(f"        {line}")
            lines.append("    }")
            lines.append("}")
        else:
            lines.append("// ⚠️ Impossible de parser le bloc #Preview")
    else:
        lines.append("// ⚠️ Impossible de parser le bloc #Preview")

    lines.append("")
    return '\n'.join(lines)


# ── Main ───────────────────────────────────────────────────────

def main():
    # Déterminer le chemin du projet
    if len(sys.argv) > 1:
        project_path = sys.argv[1]
    else:
        project_path = os.getcwd()

    project_path = os.path.abspath(project_path)
    output_path = os.path.join(project_path, OUTPUT_DIR)

    print(f"🔍 Scan du projet : {project_path}")
    print()

    # 1. Trouver tous les fichiers Swift
    swift_files = find_swift_files(project_path)
    print(f"   📄 {len(swift_files)} fichiers Swift trouvés")

    # 2. Parser tous les types et previews
    all_types: dict[str, TypeDefinition] = {}
    all_previews: list[PreviewBlock] = []

    for file_path in swift_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                source = f.read()
        except (UnicodeDecodeError, PermissionError):
            continue

        # Parser les types
        types = parse_type_definitions(file_path, source)
        for td in types:
            if td.name not in all_types:
                all_types[td.name] = td

        # Parser les previews
        previews = parse_preview_blocks(file_path, source)
        all_previews.extend(previews)

    print(f"   🧩 {len(all_types)} types trouvés ({', '.join(sorted(all_types.keys())[:10])}{'...' if len(all_types) > 10 else ''})")
    print(f"   👁️  {len(all_previews)} #Preview trouvés")
    print()

    if not all_previews:
        print("⚠️  Aucun #Preview trouvé dans le projet.")
        print("   Assure-toi que tes vues contiennent des blocs #Preview { ... }")
        sys.exit(0)

    # 3. Créer le dossier de sortie
    os.makedirs(output_path, exist_ok=True)

    # 4. Générer les fichiers de preview
    generated = []
    for i, preview in enumerate(all_previews):
        # Types du même fichier que le preview
        same_file_types = [td for td in all_types.values() if td.file_path == preview.file_path]

        # Générer le fichier
        output_content = generate_preview_file(preview, all_types, same_file_types)

        # Nom du fichier de sortie
        if len(all_previews) > 1:
            # Si plusieurs previews dans le même fichier, numéroter
            same_file_previews = [p for p in all_previews if p.file_name == preview.file_name]
            if len(same_file_previews) > 1:
                idx = same_file_previews.index(preview) + 1
                output_name = f"{preview.file_name}_Preview{idx}.swift"
            else:
                output_name = f"{preview.file_name}.swift"
        else:
            output_name = f"{preview.file_name}.swift"

        output_file = os.path.join(output_path, output_name)

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output_content)

        generated.append((output_name, preview.file_path, preview.parent_view))
        print(f"   ✅ {output_name}")
        print(f"      ← {preview.file_path}")
        if preview.parent_view:
            print(f"      📱 Vue principale : {preview.parent_view}")
        
        # Lister les dépendances résolues
        same_file_type_names = {td.name for td in same_file_types}
        known_names = set(all_types.keys())
        preview_refs = find_type_references(preview.source_code, known_names)
        all_needed = set(same_file_type_names) | preview_refs
        resolved = resolve_dependencies(all_needed, all_types)
        dep_names = [td.name for td in resolved if td.file_path != preview.file_path]
        if dep_names:
            print(f"      🔗 Dépendances externes : {', '.join(dep_names)}")
        print()

    print(f"{'─' * 50}")
    print(f"🎉 {len(generated)} fichier(s) généré(s) dans {OUTPUT_DIR}/")
    print(f"   Tu peux maintenant : git add PreviewRenders/ && git push")
    print(f"   Le workflow GitHub Actions va générer les PNGs automatiquement.")


if __name__ == "__main__":
    main()