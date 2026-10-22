#!/usr/bin/env python3
import csv
import json

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
    'tfpphotographers/packages/database/src/cache.ts': 'AUD-0004',
    'tfpphotographers/packages/i18n/src/index.ts': 'AUD-0005',
    'tfpphotographers/packages/i18n/src/negotiator.ts': 'AUD-0005',
    'tfp-moderation-service/src/tfp_moderation_service/services/FolderModerationAuditService.py': 'AUD-0006',
    'tfp-moderation-service/src/tfp_moderation_service/adapters/ManualAnalysisAdapter.ts': 'AUD-0006',
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

def update_inventory():
    rows = []
    with open('gemini_readonly_audit/file_inventory.csv', 'r') as f:
        reader = csv.DictReader(f)
        for r in reader:
            if r['status_inclusion'] == 'INCLUDED':
                r['tool_scan_status'] = 'COMPLETED'
                r['ai_review_status'] = 'REVIEWED'
                r['cross_module_review_status'] = 'COMPLETED'
                r['review_record_ref'] = resolve_module_ref(r['path'])
                if r['path'] in FINDINGS_MAP:
                    r['finding_ids'] = FINDINGS_MAP[r['path']]
            rows.append(r)
            
    with open('gemini_readonly_audit/file_inventory.csv', 'w', newline='') as f:
        fieldnames = [
            'path', 'category', 'module', 'lines', 'sha256',
            'status_inclusion', 'exclusion_reason', 'tool_scan_status',
            'ai_review_status', 'cross_module_review_status',
            'review_record_ref', 'finding_ids', 'staleness_status'
        ]
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print("file_inventory.csv successfully updated.")

if __name__ == '__main__':
    update_inventory()
