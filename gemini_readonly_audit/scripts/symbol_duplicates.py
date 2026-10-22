#!/usr/bin/env python3
import os
import re
import csv
import json
import collections

SCAN_EXTENSIONS = {'.ts', '.tsx', '.js', '.mjs', '.cjs', '.astro', '.py'}

def load_included_source_files():
    files = []
    with open('gemini_readonly_audit/file_inventory.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in r:
            if row['status_inclusion'] == 'INCLUDED':
                ext = os.path.splitext(row['path'])[1].lower()
                if ext in SCAN_EXTENSIONS:
                    files.append(row['path'])
    return files

def is_test_or_fixture_path(path):
    parts = path.replace('\\', '/').split('/')
    test_dirs = {'tests', 'qa', '__tests__', 'fixtures', 'test'}
    if any(p.lower() in test_dirs for p in parts[:-1]):
        return True
    base = parts[-1].lower()
    if '.test.' in base or '.spec.' in base or base.startswith('test_') or base.endswith('_test.py'):
        return True
    return False

def scan_symbol_declarations(files):
    export_re = re.compile(r'export\s+(?:async\s+)?(?:function|class|type|interface|const|enum)\s+([a-zA-Z0-9_]+)')
    
    symbol_locations = collections.defaultdict(list)
    for path in files:
        if not os.path.isfile(path) or is_test_or_fixture_path(path):
            continue
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                for idx, line in enumerate(f, 1):
                    match = export_re.search(line)
                    if match:
                        sym = match.group(1)
                        symbol_locations[sym].append((path, idx))
        except Exception:
            pass
            
    # Include symbols that appear across multiple locations
    multi_symbols = {sym: locs for sym, locs in symbol_locations.items() if len(locs) > 1}
    return multi_symbols

def main():
    files = []
    with open('gemini_readonly_audit/file_inventory.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['status_inclusion'] == 'INCLUDED':
                ext = os.path.splitext(row['path'])[1].lower()
                if ext in SCAN_EXTENSIONS:
                    files.append(row['path'])
                    
    print(f"Loaded {len(files)} source files for lexical symbol scan.")
    multi_symbols = scan_symbol_declarations(files)
    print(f"Found {len(multi_symbols)} multi-defined exported symbols across production files.")
    
    out_json = 'gemini_readonly_audit/symbol_duplication.json'
    results = {
        'detector_metadata': {
            'scanner_type': 'lexical_regex_symbol_export_scan',
            'pattern': r'export (?:async )?(?:function|class|type|interface|const|enum) <identifier>',
            'production_files_scanned': len([f for f in files if not is_test_or_fixture_path(f)]),
            'test_files_excluded': len([f for f in files if is_test_or_fixture_path(f)]),
        },
        'multi_symbols': multi_symbols
    }
    
    with open(out_json, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)
    print(f"Complete results saved to {out_json}")

if __name__ == '__main__':
    main()
