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
        for row in reader:
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

def scan_layer_violations(files):
    violations = []
    import_re = re.compile(r'''(?:import\s+.*?from\s+['"]([^'"]+)['"]|require\(['"]([^'"]+)['"]\)|from\s+([a-zA-Z0-9_.]+)\s+import|import\s+([a-zA-Z0-9_.]+))''')
    
    for path in files:
        if not os.path.isfile(path):
            continue
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except Exception:
            continue
            
        for line_no, line in enumerate(lines, 1):
            for match in import_re.finditer(line):
                target = match.group(1) or match.group(2) or match.group(3) or match.group(4)
                if not target:
                    continue
                
                # Check 1: apps/web importing from apps/api
                if 'apps/web' in path and ('apps/api' in target or '@tfp/api' in target):
                    violations.append({
                        'type': 'WEB_IMPORTS_API',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'HIGH',
                        'detail': 'Astro web application directly imports from Fastify API application'
                    })
                
                # Check 2: apps/web importing @tfp/database or @prisma
                if 'apps/web' in path and ('@tfp/database' in target or '@prisma/client' in target or 'packages/database' in target):
                    violations.append({
                        'type': 'WEB_IMPORTS_DATABASE',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'HIGH',
                        'detail': 'Astro web frontend directly imports Prisma database layer'
                    })
                    
                # Check 3: packages/* importing from apps/*
                if 'tfpphotographers/packages/' in path and ('/apps/' in target or '@tfp/web' in target or '@tfp/api' in target or '@tfp/mobile' in target):
                    violations.append({
                        'type': 'PACKAGE_IMPORTS_APP',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'HIGH',
                        'detail': 'Shared package imports from application layer (inverted dependency)'
                    })
                    
                # Check 4: apps/mobile clean architecture boundary violations
                if 'apps/mobile/src/domain' in path and ('infrastructure' in target or 'presentation' in target):
                    violations.append({
                        'type': 'MOBILE_DOMAIN_LEAK',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'MEDIUM',
                        'detail': 'Mobile domain layer imports infrastructure or presentation'
                    })
                if 'apps/mobile/src/application' in path and 'presentation' in target:
                    violations.append({
                        'type': 'MOBILE_APP_IMPORTS_PRESENTATION',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'MEDIUM',
                        'detail': 'Mobile application/use-case layer imports presentation layer'
                    })
                    
                # Check 5: Path traversal escaping module root (e.g. ../../../../apps/)
                if target.startswith('../') and '/apps/' in target:
                    violations.append({
                        'type': 'PATH_TRAVERSAL_APP_CROSSING',
                        'file': path,
                        'line': line_no,
                        'import': target,
                        'severity': 'MEDIUM',
                        'detail': 'Relative import traverses across application boundaries'
                    })
    return violations

def scan_large_files(files):
    large_files = []
    for path in files:
        if not os.path.isfile(path):
            continue
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = len(f.readlines())
            if lines >= 500:
                large_files.append((path, lines))
        except Exception:
            pass
    large_files.sort(key=lambda x: -x[1])
    return large_files

def scan_block_duplicates(files, min_lines=12):
    # Lexical rolling window hash on normalized non-empty, non-comment lines
    window_hashes = collections.defaultdict(list)
    
    for path in files:
        if not os.path.isfile(path):
            continue
        # Exclude test suites and test fixtures using component-aware boundary matching
        if is_test_or_fixture_path(path):
            continue
            
        try:
            with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                raw_lines = f.readlines()
        except Exception:
            continue
            
        cleaned = []
        for idx, l in enumerate(raw_lines, 1):
            norm = l.strip()
            if not norm or norm.startswith('//') or norm.startswith('#') or norm.startswith('/*') or norm.startswith('*'):
                continue
            cleaned.append((idx, norm))
            
        if len(cleaned) < min_lines:
            continue
            
        for i in range(len(cleaned) - min_lines + 1):
            block = tuple(cleaned[j][1] for j in range(i, i + min_lines))
            start_line = cleaned[i][0]
            end_line = cleaned[i + min_lines - 1][0]
            h = hash(block)
            window_hashes[h].append((path, start_line, end_line, block))
            
    # Filter to duplicates appearing across DIFFERENT files
    candidate_groups = []
    seen_blocks = set()
    
    for h, occurrences in window_hashes.items():
        unique_files = {occ[0] for occ in occurrences}
        if len(unique_files) > 1:
            first_block = occurrences[0][3]
            # Use entire normalized block tuple to eliminate boundary-line hash collisions
            if first_block in seen_blocks:
                continue
            seen_blocks.add(first_block)
            
            by_file = {}
            for occ in occurrences:
                if occ[0] not in by_file:
                    by_file[occ[0]] = (occ[1], occ[2])
            if len(by_file) > 1:
                candidate_groups.append({
                    'lines_count': min_lines,
                    'snippet': first_block[:3],
                    'occurrences': by_file
                })
    return candidate_groups

def main():
    files = load_included_source_files()
    print(f"Loaded {len(files)} source files for mechanical analysis.")
    
    # 1. Layer Violations
    violations = scan_layer_violations(files)
    print(f"Layer boundary violations found: {len(violations)}")
    
    # 2. Large files
    large_files = scan_large_files(files)
    print(f"Files >= 500 lines: {len(large_files)}")
    
    # 3. Block duplicates (excluding tests and fixtures via component-aware check)
    dup_candidates = scan_block_duplicates(files, min_lines=12)
    print(f"Block duplicate candidate groups (>= 12 lines across distinct production files): {len(dup_candidates)}")
    
    # Persist COMPLETE results without truncation
    results = {
        'detector_metadata': {
            'scanner_type': 'lexical_rolling_hash_window',
            'min_lines_threshold': 12,
            'source_files_considered': len(files),
            'production_files_scanned_for_dups': len([f for f in files if not is_test_or_fixture_path(f)]),
            'test_files_excluded_from_dups': len([f for f in files if is_test_or_fixture_path(f)]),
        },
        'layer_violations': violations,
        'large_files': large_files,
        'duplicate_candidates': dup_candidates
    }
    
    out_json = 'gemini_readonly_audit/mechanical_scan_results.json'
    with open(out_json, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)
    print(f"Complete results saved to {out_json} ({len(large_files)} large files, {len(dup_candidates)} duplicate groups, {len(violations)} layer violations).")

if __name__ == '__main__':
    main()
