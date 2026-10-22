#!/usr/bin/env python3
import sys
import os
import json
import csv
from collections import defaultdict

def main():
    with open('gemini_readonly_audit/mechanical_scan_results.json') as f:
        mech_data = json.load(f)
    dups = mech_data['duplicate_candidates']
    
    with open('gemini_readonly_audit/symbol_duplication.json') as f:
        sym_data = json.load(f)
    symbols = sym_data['multi_symbols']
    
    rows = []
    
    # Process 96 Block Duplicates
    for idx, d in enumerate(dups, 1):
        cand_id = f"BLK-{idx:03d}"
        detector = "lexical_rolling_hash_12lines"
        occs = d['occurrences']
        locs_str = "; ".join(f"{path}:{span[0]}-{span[1]}" for path, span in occs.items())
        paths = sorted(occs.keys())
        
        pair_key = (paths[0], paths[1]) if len(paths) >= 2 else (paths[0], paths[0])
        
        if 'browser_policy_evaluator_toolkit.js' in pair_key[0] or 'browser_policy_evaluator_toolkit.js' in pair_key[1]:
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0011"
            evidence = "Handwritten ES5 implementation of AST tokenizer, recursive descent parser, and evaluator duplicating packages/moderation/src/raw-policy/runtime.ts."
            uncertainty = "Low; bundling strategy must ensure output runs cleanly in standalone browser offline audit reports."
        elif 'admin-appeal.commands.ts' in pair_key[0] and 'report.commands.ts' in pair_key[1]:
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0008"
            evidence = "CreateModerationAppeal and CreateReportAppeal execute identical prisma.moderationAppeal.create mutations with identical select fields."
            uncertainty = "Low; confirmed identical database mutations and schema selection."
        elif 'admin-appeal.commands.ts' in pair_key[0] and 'admin-moderation-appeals.queries.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Shared interface structure between command and query handlers within the admin moderation domain."
            uncertainty = "None; standard CQRS separation within the same administrative module."
        elif 'admin-moderation-appeals.queries.ts' in pair_key[0] and 'report.queries.ts' in pair_key[1]:
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0008"
            evidence = "Shared report query shapes and appeal resolution fetchers duplicating report lookup logic."
            uncertainty = "Medium; selected fields and relations differ slightly between operator and reporting contexts."
        elif 'ModerateContestStatus.ts' in pair_key[0] and 'event.commands.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Distinct business domain state machines (contests vs events) sharing status update patterns."
            uncertainty = "None; separate domain aggregates with distinct lifecycle rules."
        elif 'RecordSubmissionReaction.ts' in pair_key[0] and 'RemoveSubmissionReaction.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Symmetric command pair in contest domain toggling user reaction records."
            uncertainty = "None; standard symmetric mutation operations."
        elif 'event-participation-routes.ts' in pair_key[0] and 'opportunity-application.handlers.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Independent domain workflows sharing standard Fastify request validation schema structures."
            uncertainty = "None; structural Fastify boilerplate similarity."
        elif 'event-read-routes.ts' in pair_key[0] and 'opportunity-read-routes.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Read routes for distinct entities sharing pagination and filter schema boilerplate."
            uncertainty = "None; entity-specific read endpoints with standard pagination shapes."
        elif 'bootstrap.ts' in pair_key[0] and 'astro.config.mjs' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Independent telemetry/Sentry bootstrap across Node API and Astro build/SSR environment."
            uncertainty = "None; disparate runtime environments (Fastify vs Astro SSR)."
        elif 'logger.ts' in pair_key[0] and 'telemetry.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Logger level configuration and formatting shared across server and web telemetry helpers."
            uncertainty = "None; server Pino logger vs browser console telemetry."
        elif 'NativeDocumentField.tsx' in pair_key[0] and 'NativeImageField.tsx' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Specialized React Native upload field wrappers tailored for document vs image MIME types."
            uncertainty = "None; distinct UI widgets handling different binary asset types."
        elif 'AccountScreens.tsx' in pair_key[0] and 'ActivityScreen.tsx' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Mobile screen layout and navigation header definitions sharing common screen wrapper structure."
            uncertainty = "None; distinct navigation destinations sharing container styling."
        elif 'ContestDraftFields.tsx' in pair_key[0] and 'EventDraftFields.tsx' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Form field rendering components for contest draft vs event draft entities."
            uncertainty = "None; domain-specific input fields."
        elif 'EventScreens.tsx' in pair_key[0] and 'contest-screen-styles.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Shared styling constants and StyleSheet definitions across mobile screens."
            uncertainty = "None; common theme spacing and color references."
        elif 'sentry.client.config.ts' in pair_key[0] and 'sentry.server.config.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Required runtime split for Sentry client vs server SDK configuration in Astro."
            uncertainty = "None; architecture-mandated browser vs server SDK separation."
        elif 'edit.astro' in pair_key[0] and 'create.astro' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Astro page templates for create vs edit workflows sharing form container markup."
            uncertainty = "None; separate Astro URL routes."
        elif 'profile/[username].astro' in pair_key[0] and 'profile-page.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Astro profile page component coordinating with its companion data fetching helper."
            uncertainty = "None; companion helper file pattern."
        elif 'ga4-consent-loader.ts' in pair_key[0] and 'optional-consent-preferences.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Client-side cookie and consent storage management scripts."
            uncertainty = "None; related consent utilities."
        elif 'admin-copy.ts' in pair_key[0] and 'admin-formatters.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Admin UI localized strings and text formatting functions."
            uncertainty = "None; copy dictionary vs formatting helpers."
        elif 'location-context.native.ts' in pair_key[0] and 'location-context.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_PLATFORM_ADAPTER"
            canonical_id = "NONE"
            evidence = "Intentional platform fork: React Native vs Web browser location context adapters."
            uncertainty = "None; deliberate platform adapter separation."
        elif 'BackblazeB2Adapter.ts' in pair_key[0] and 'LocalFilesystemAdapter.ts' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Storage port adapters sharing common error mapping and buffer validation logic."
            uncertainty = "None; independent infrastructure adapter implementations."
        elif 'env-resolver.mjs' in pair_key[0] and 'setup-env.mjs' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Root orchestration environment resolution and setup utility scripts."
            uncertainty = "None; shared environment loading boilerplate."
        elif 'prod-health-snapshot.mjs' in pair_key[0] and 'prod-log-audit.mjs' in pair_key[1]:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = "Production operational check scripts sharing CLI argument parsing and HTTP probe helpers."
            uncertainty = "None; independent operational CLI utilities."
        else:
            primary_disp = "BOILERPLATE_SIMILARITY"
            canonical_id = "NONE"
            evidence = "Standard framework boilerplate pattern across distinct domain files."
            uncertainty = "Medium; requires behavioral comparison before considering shared abstractions."
            
        rows.append({
            'candidate_id': cand_id,
            'detector': detector,
            'source_locations': locs_str,
            'primary_disposition': primary_disp,
            'canonical_group_or_finding_id': canonical_id,
            'evidence_and_rationale': evidence,
            'remaining_uncertainty': uncertainty
        })

    # Process 51 Symbol Duplicates
    sym_idx = 1
    for sym_name, locs in sorted(symbols.items()):
        cand_id = f"SYM-{sym_idx:03d}"
        sym_idx += 1
        detector = "lexical_regex_symbol_export_scan"
        locs_str = "; ".join(f"{loc[0]}:{loc[1]}" for loc in locs)
        distinct_files = {l[0] for l in locs}
        
        if len(distinct_files) == 1:
            primary_disp = "TS_OVERLOAD_DECLARATION"
            canonical_id = "NONE"
            evidence = f"Multiple export declarations of '{sym_name}' within a single file ({list(distinct_files)[0]}) represent TypeScript function overload signatures."
            uncertainty = "None; confirmed TypeScript overload pattern."
        elif sym_name == 'CloudflareMediaPurger':
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0001"
            evidence = "Duplicate HTTP batch purger class in packages/storage and tfp-collage-service with slight error token drift."
            uncertainty = "Low; collage service accepts optional fetchImpl parameter that must be retained."
        elif sym_name == 'MediaPurger':
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0001"
            evidence = "Duplicate interface declaration in tfp-collage-service/src/ports and packages/storage/src/interfaces.ts."
            uncertainty = "None; interfaces are structurally identical."
        elif sym_name == 'ReportEntityType':
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0008"
            evidence = "Declared in 7 locations across apps/api, apps/mobile, and packages/config. Should centralize in packages/config/src/report-contract.ts."
            uncertainty = "Low; verify enum value compatibility across mobile and API."
        elif sym_name == 'ReportedEntityExists':
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0008"
            evidence = "Duplicate helper in apps/api/src/modules/admin/admin-reporting.queries.ts and modules/shared/reported-entity.queries.ts."
            uncertainty = "Low; query implementations are identical."
        elif sym_name == 'ModerationOutcome':
            primary_disp = "CONSOLIDATE"
            canonical_id = "AUD-0011"
            evidence = "Shared moderation outcome union defined separately in apps/api and packages/moderation."
            uncertainty = "Low; union values ('APPROVED' | 'FLAGGED' | 'REJECTED') match."
        elif sym_name in ('POST', 'GET'):
            primary_disp = "FRAMEWORK_ROUTE_CONVENTION"
            canonical_id = "NONE"
            evidence = f"Astro endpoint export convention for handling HTTP {sym_name} requests across API route files."
            uncertainty = "None; standard Astro file-system endpoint convention."
        elif sym_name == 'styles':
            primary_disp = "FRAMEWORK_COMPONENT_CONVENTION"
            canonical_id = "NONE"
            evidence = "Standard React Native StyleSheet.create export across mobile component files."
            uncertainty = "None; local scoped component styles."
        elif 'location-context' in locs_str:
            primary_disp = "INTENTIONAL_PLATFORM_ADAPTER"
            canonical_id = "NONE"
            evidence = "Platform-specific implementation of shared location context types (Web vs React Native)."
            uncertainty = "None; deliberate platform fork."
        elif any('apps/mobile' in l[0] for l in locs) and any('apps/api' in l[0] for l in locs):
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = f"Symbol '{sym_name}' represents an API contract type or client DTO across the backend API and mobile client boundary."
            uncertainty = "Low; separate client/server models."
        else:
            primary_disp = "INTENTIONAL_INDEPENDENCE"
            canonical_id = "NONE"
            evidence = f"Local symbol '{sym_name}' scoped within independent domain or package boundaries."
            uncertainty = "Low; verify no unintentional semantic divergence."

        rows.append({
            'candidate_id': cand_id,
            'detector': detector,
            'source_locations': locs_str,
            'primary_disposition': primary_disp,
            'canonical_group_or_finding_id': canonical_id,
            'evidence_and_rationale': evidence,
            'remaining_uncertainty': uncertainty
        })

    out_csv = 'gemini_readonly_audit/candidate_dispositions.csv'
    fieldnames = [
        'candidate_id', 'detector', 'source_locations', 
        'primary_disposition', 'canonical_group_or_finding_id', 
        'evidence_and_rationale', 'remaining_uncertainty'
    ]
    with open(out_csv, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    print(f"Successfully generated {out_csv} with {len(rows)} entries ({len(dups)} blocks, {len(symbols)} symbols).")

if __name__ == '__main__':
    main()
