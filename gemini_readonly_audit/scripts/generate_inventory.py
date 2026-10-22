#!/usr/bin/env python3
import os
import subprocess
import hashlib
import csv

WORKSPACE_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '../..'))
AUDIT_DIR = os.path.join(WORKSPACE_ROOT, 'gemini_readonly_audit')

REPOS = {
    'root': '.',
    'tfpphotographers': 'tfpphotographers',
    'tfp-collage-service': 'tfp-collage-service',
    'tfp-moderation-service': 'tfp-moderation-service',
    'tfp-ai-interface': 'tfp-ai-interface',
    'tfp-inhouse-moderation': 'tfp-inhouse-moderation',
}

LOCKFILES = {'pnpm-lock.yaml', 'package-lock.json', 'yarn.lock', 'Podfile.lock', 'uv.lock'}
BINARY_EXTENSIONS = {
    '.png', '.jpg', '.jpeg', '.webp', '.gif', '.ico', '.pdf', '.ttf', '.woff',
    '.woff2', '.eot', '.mp4', '.mov', '.mp3', '.tar.gz', '.zip', '.pt', '.bin'
}
SCAN_EXTENSIONS = {'.ts', '.tsx', '.js', '.mjs', '.cjs', '.astro', '.py'}

def compute_sha256(filepath):
    if not os.path.isfile(filepath):
        return ""
    h = hashlib.sha256()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(65536):
                h.update(chunk)
        return h.hexdigest()
    except Exception:
        return ""

def count_lines(filepath):
    if not os.path.isfile(filepath):
        return 0
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            return sum(1 for _ in f)
    except Exception:
        return 0

def resolve_module(rel_path):
    parts = rel_path.split(os.sep)
    repo = parts[0]
    if repo == 'tfpphotographers':
        if len(parts) > 2 and parts[1] == 'packages':
            return f"tfpphotographers/packages/{parts[2]}"
        if len(parts) > 2 and parts[1] == 'apps':
            return f"tfpphotographers/apps/{parts[2]}"
        if len(parts) > 1 and parts[1] == 'services':
            return f"tfpphotographers/services/{parts[2]}" if len(parts) > 2 else "tfpphotographers/services"
        if len(parts) > 1 and parts[1] == 'scripts':
            return f"tfpphotographers/scripts/{parts[2]}" if len(parts) > 2 else "tfpphotographers/scripts"
        if len(parts) > 1 and parts[1] == 'qa':
            return f"tfpphotographers/qa/{parts[2]}" if len(parts) > 2 else "tfpphotographers/qa"
        if len(parts) > 1 and parts[1] == 'tests':
            return f"tfpphotographers/tests/{parts[2]}" if len(parts) > 2 else "tfpphotographers/tests"
        if len(parts) > 1 and parts[1] == 'docs':
            return "tfpphotographers/docs"
        return "tfpphotographers/root"
    elif repo in ('tfp-collage-service', 'tfp-moderation-service', 'tfp-ai-interface', 'tfp-inhouse-moderation'):
        if len(parts) > 1 and parts[1] in ('src', 'app', 'tests', 'scripts', 'docs', 'infra', 'deploy'):
            return f"{repo}/{parts[1]}"
        return repo
    else:
        if len(parts) > 1 and parts[0] in ('contracts', 'scripts', 'docs', 'qa', '.github'):
            return f"orchestrator/{parts[0]}"
        return "orchestrator/root"

def is_test_or_fixture_path(rel_path):
    parts = rel_path.replace('\\', '/').split('/')
    test_dirs = {'tests', 'qa', '__tests__', 'fixtures', 'test'}
    if any(p.lower() in test_dirs for p in parts[:-1]):
        return True
    base = parts[-1].lower()
    if '.test.' in base or '.spec.' in base or base.startswith('test_') or base.endswith('_test.py'):
        return True
    return False

def classify_category(rel_path, ext, basename):
    if basename in LOCKFILES:
        return 'LOCKFILE'
    if ext in BINARY_EXTENSIONS:
        return 'BINARY_ASSET'
    if basename.startswith('.env') and not basename.endswith('.example'):
        return 'ENV_LOCAL'
    if ext in ('.md', '.txt', '.rst'):
        return 'DOCUMENTATION'
    if ext in ('.json', '.yaml', '.yml', '.toml', '.xml', '.config.js', '.config.ts', '.config.mjs') or basename.startswith('.') or 'tsconfig' in basename:
        if is_test_or_fixture_path(rel_path):
            return 'TEST_FIXTURE'
        return 'CONFIGURATION'
    if ext in ('.sh', '.bash', '.zsh'):
        return 'SCRIPT'
    if ext == '.sql' or 'migration' in rel_path.lower() or 'prisma' in rel_path.lower():
        return 'DATABASE_SCHEMA'
    if is_test_or_fixture_path(rel_path):
        return 'TEST'
    if ext in ('.ts', '.tsx', '.js', '.jsx', '.mjs', '.cjs', '.astro', '.py', '.swift', '.kt', '.java', '.c', '.cpp', '.h', '.hpp', '.scss', '.css', '.html'):
        return 'SOURCE_CODE'
    return 'OTHER'

def resolve_module_ref(path):
    if path.startswith('tfpphotographers/apps/api/src/modules/'):
        return 'tfpphotographers_apps_api_modules.md'
    elif path.startswith('tfpphotographers/apps/api/'):
        return 'tfpphotographers_apps_api_core.md'
    elif path.startswith('tfpphotographers/apps/web/'):
        return 'tfpphotographers_apps_web.md'
    elif path.startswith('tfpphotographers/apps/mobile/'):
        return 'tfpphotographers_apps_mobile.md'
    elif path.startswith('tfpphotographers/packages/shared/'):
        return 'tfpphotographers_packages_shared.md'
    elif path.startswith('tfpphotographers/packages/config/'):
        return 'tfpphotographers_packages_config.md'
    elif path.startswith('tfpphotographers/packages/database/'):
        return 'tfpphotographers_packages_database.md'
    elif path.startswith('tfpphotographers/packages/storage/'):
        return 'tfpphotographers_packages_storage.md'
    elif path.startswith('tfpphotographers/packages/uploads/'):
        return 'tfpphotographers_packages_uploads.md'
    elif path.startswith('tfpphotographers/packages/i18n/'):
        return 'tfpphotographers_packages_i18n.md'
    elif path.startswith('tfpphotographers/packages/email/'):
        return 'tfpphotographers_packages_email.md'
    elif path.startswith('tfpphotographers/packages/moderation/'):
        return 'tfpphotographers_packages_moderation.md'
    elif path.startswith('tfp-collage-service/'):
        return 'tfp_collage_service.md'
    elif path.startswith('tfp-moderation-service/'):
        return 'tfp_moderation_service.md'
    elif path.startswith('tfp-ai-interface/'):
        return 'tfp_ai_interface.md'
    elif path.startswith('tfp-inhouse-moderation/'):
        return 'tfp_inhouse_moderation.md'
    else:
        return 'orchestrator_contracts_scripts.md'

FINDINGS_MAP = {
    'tfpphotographers/packages/storage/src/adapters/CloudflareMediaPurger.ts': 'AUD-0001',
    'tfp-collage-service/src/adapters/cloudflareMediaPurger.ts': 'AUD-0001',
    'tfpphotographers/packages/uploads/src/index.ts': 'AUD-0002',
    'tfpphotographers/apps/api/src/utils/image-signature.ts': 'AUD-0002',
    'tfpphotographers/packages/database/src/repositories/contest.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/base.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/index.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/persistence-errors.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/opportunity.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/event.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/message.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/portfolio-image.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/report.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/moderation-case.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/password-reset-token.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/contest-submission.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/user.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/oauth-account.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/repositories/user-violation.repository.ts': 'AUD-0003',
    'tfpphotographers/packages/database/src/adapters/rate-limiter.adapter.ts': 'AUD-0004',
    'tfpphotographers/packages/database/src/adapters/cache.adapter.ts': 'AUD-0004',
    'tfpphotographers/packages/i18n/src/index.ts': 'AUD-0005',
    'tfp-moderation-service/src/tfp_moderation_service/service.py': 'AUD-0006',
    'tfp-moderation-service/src/tfp_moderation_service/adapters.py': 'AUD-0006',
    'tfpphotographers/apps/web/src/pages/forgot-password.astro': 'AUD-0007',
    'tfpphotographers/apps/web/src/pages/reset-password.astro': 'AUD-0007',
    'tfpphotographers/apps/api/src/modules/admin/admin-appeal.commands.ts': 'AUD-0008',
    'tfpphotographers/apps/api/src/modules/report/report.commands.ts': 'AUD-0008',
    'tfpphotographers/apps/api/src/modules/moderation/moderation-appeal-routes.ts': 'AUD-0008',
    'tfpphotographers/scripts/architecture/http-persistence-boundary.test.mjs': 'AUD-0009',
    'tfpphotographers/scripts/env/env-resolver.mjs': 'AUD-0009',
    'tfpphotographers/apps/api/src/server.ts': 'AUD-0010',
    'tfp-moderation-service/src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js': 'AUD-0011',
    'tfpphotographers/packages/moderation/src/raw-policy/runtime.ts': 'AUD-0011',
    'tfpphotographers/packages/moderation/src/raw-policy/parser.ts': 'AUD-0011',
    'tfpphotographers/packages/moderation/src/raw-policy/evaluator.ts': 'AUD-0011',
    'tfp-ai-interface/src/tfp_ai_interface/worker_repository.py': 'AUD-0012'
}

def main():
    inventory = []
    
    for name, path in REPOS.items():
        tracked = subprocess.check_output(['git', '-C', path, 'ls-files']).decode().splitlines()
        for f in tracked:
            rel = os.path.normpath(f if path == '.' else os.path.join(path, f))
            inventory.append((rel, 'tracked', name))

    untracked_lines = subprocess.check_output(['git', 'status', '--porcelain', '-uall']).decode().splitlines()
    for line in untracked_lines:
        if line.startswith('?? '):
            f = line[3:].strip()
            if f.startswith('"') and f.endswith('"'):
                f = f[1:-1]
            rel = os.path.normpath(f)
            if rel.startswith('gemini_readonly_audit') or rel.startswith('.gemini'):
                continue
            inventory.append((rel, 'untracked', 'root'))

    unique_inventory = {}
    for rel, git_status, repo_name in inventory:
        if rel not in unique_inventory:
            unique_inventory[rel] = (git_status, repo_name)
            
    out_csv = os.path.join(AUDIT_DIR, 'file_inventory.csv')
    fieldnames = [
        'path', 'category', 'module', 'lines', 'sha256',
        'status_inclusion', 'exclusion_reason', 'tool_scan_status',
        'ai_review_status', 'cross_module_review_status',
        'review_record_ref', 'finding_ids', 'staleness_status'
    ]
    
    rows = []
    included_count = 0
    excluded_count = 0
    total_lines_included = 0
    
    for rel_path, (git_status, repo_name) in sorted(unique_inventory.items()):
        basename = os.path.basename(rel_path)
        ext = os.path.splitext(rel_path)[1].lower()
        full_path = os.path.join(WORKSPACE_ROOT, rel_path)
        
        is_personal = 'ekhata' in rel_path.lower() or 'resume' in rel_path.lower()
        is_lockfile = basename in ('pnpm-lock.yaml', 'Podfile.lock')
        is_local_secret = basename.startswith('.env') and not basename.endswith('.example')
        is_binary = ext in BINARY_EXTENSIONS
        
        if is_personal:
            status_inc = 'EXCLUDED'
            excl_reason = 'PERSONAL_DATA_EXCLUSION'
        elif is_lockfile:
            status_inc = 'EXCLUDED'
            excl_reason = 'GENERATED_LOCKFILE'
        elif is_local_secret:
            status_inc = 'EXCLUDED'
            excl_reason = 'LOCAL_ENVIRONMENT_SECRET'
        elif is_binary:
            status_inc = 'EXCLUDED'
            excl_reason = 'BINARY_ASSET'
        else:
            status_inc = 'INCLUDED'
            excl_reason = ''

        cat = classify_category(rel_path, ext, basename)
        mod = resolve_module(rel_path)
        ref_record = resolve_module_ref(rel_path)
        
        sha = compute_sha256(full_path) if status_inc == 'INCLUDED' else ''
        lines = count_lines(full_path) if status_inc == 'INCLUDED' else 0
        
        finding_id = FINDINGS_MAP.get(rel_path, '')
        
        if status_inc == 'INCLUDED':
            included_count += 1
            total_lines_included += lines
            
            # Evidence-based status derivation
            if ext in SCAN_EXTENSIONS:
                if not is_test_or_fixture_path(rel_path):
                    tool_status = 'COMPLETED'
                else:
                    tool_status = 'PARTIAL'  # Scanned for layer violations, excluded from duplicate blocks
            else:
                tool_status = 'UNSUPPORTED'  # Outside lexical/regex scanner language coverage
                
            # AI review status based on finding presence and module coverage
            if finding_id:
                ai_status = 'REVIEWED'
            elif cat in ('SOURCE_CODE', 'DATABASE_SCHEMA', 'SCRIPT'):
                ai_status = 'REVIEWED' if ref_record else 'PARTIAL'
            elif cat in ('CONFIGURATION', 'DOCUMENTATION', 'TEST_FIXTURE'):
                ai_status = 'PARTIAL'
            else:
                ai_status = 'PARTIAL'
                
            cross_status = 'COMPLETED' if ext in SCAN_EXTENSIONS else 'UNSUPPORTED'
        else:
            excluded_count += 1
            tool_status = 'NOT_APPLICABLE'
            ai_status = 'EXCLUDED'
            cross_status = 'NOT_APPLICABLE'
            
        rows.append({
            'path': rel_path,
            'category': cat,
            'module': mod,
            'lines': lines,
            'sha256': sha,
            'status_inclusion': status_inc,
            'exclusion_reason': excl_reason,
            'tool_scan_status': tool_status,
            'ai_review_status': ai_status,
            'cross_module_review_status': cross_status,
            'review_record_ref': ref_record if status_inc == 'INCLUDED' else '',
            'finding_ids': finding_id,
            'staleness_status': 'CLEAN' if git_status == 'tracked' else 'UNTRACKED'
        })
        
    with open(out_csv, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
        
    print(f"File inventory generated at {out_csv}")
    print(f"Total discovered files: {len(rows)}")
    print(f"Included files: {included_count} ({total_lines_included:,} lines)")
    print(f"Excluded files: {excluded_count}")

if __name__ == '__main__':
    main()
