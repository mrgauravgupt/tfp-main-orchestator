import * as fs from 'fs';
import * as path from 'path';

/**
 * Script to examine recent changes and identify code review areas
 */

console.log('=== Examining recent changes for code review ===\n');

// Define the files that were recently changed
const recentlyChangedFiles = [
  // API files
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/plugins/health.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/plugins/auth.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/utils/direct-upload.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/utils/direct-upload.test.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/utils/upload-validation.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/auth/auth.commands.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/auth/auth.middleware.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/auth/auth.routes.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/location/location.routes.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/api/src/modules/admin/admin.queries.ts',
  
  // Web files
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/image.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/report.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/auth-cookie.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/current-user.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/redirect.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/utils/upload-endpoints.ts',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/base.scss',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/tokens.scss',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/components/admin-shell.scss',
  '/Users/hexa/Desktop/tfp-latest/tfp-workspace/apps/web/src/styles/components/auth-modal.scss'
];

console.log('1. Examining recently changed files for code review:');
console.log('====================================================');

const reviewAreas: Array<{file: string, issues: string[]}> = [];

recentlyChangedFiles.forEach(file => {
  if (fs.existsSync(file)) {
    console.log(`\nExamining: ${file}`);
    
    try {
      const content = fs.readFileSync(file, 'utf-8');
      const lines = content.split('\n');
      
      // Look for common issues
      const issues: string[] = [];
      
      // Check for potential security issues
      lines.forEach((line, idx) => {
        const lowerLine = line.toLowerCase();
        
        // Hardcoded secrets
        if (lowerLine.includes('secret') && (lowerLine.includes('= "') || lowerLine.includes("= '"))) {
          issues.push(`Potential hardcoded secret at line ${idx + 1}: ${line.trim()}`);
        }
        
        // SQL injection possibilities
        if (lowerLine.includes('query') && lowerLine.includes('+')) {
          issues.push(`Possible SQL injection at line ${idx + 1}: ${line.trim()}`);
        }
        
        // Debug logging
        if (lowerLine.includes('console.log') || lowerLine.includes('debugger')) {
          issues.push(`Debug statement at line ${idx + 1}: ${line.trim()}`);
        }
        
        // Authorization bypass
        if (lowerLine.includes('skip') && (lowerLine.includes('auth') || lowerLine.includes('permission'))) {
          issues.push(`Potential auth skip at line ${idx + 1}: ${line.trim()}`);
        }
        
        // Unsafe eval
        if (lowerLine.includes('eval(') || lowerLine.includes('Function(')) {
          issues.push(`Unsafe eval at line ${idx + 1}: ${line.trim()}`);
        }
      });
      
      // Check for error handling issues
      if (content.includes('try ') && !content.includes('catch') && !content.includes('finally')) {
        issues.push('Has try block but no catch/finally - potential error handling issue');
      }
      
      // Check for common patterns
      if (lines.length > 0) {
        // Check for deeply nested structures
        let maxNesting = 0;
        lines.forEach(line => {
          const trimmed = line.trim();
          if (!trimmed.startsWith('//') && !trimmed.startsWith('/*')) {
            const nesting = line.search(/\S|$/);
            maxNesting = Math.max(maxNesting, nesting);
          }
        });
        
        if (maxNesting > 40) {
          issues.push(`Highly nested code detected (max indentation: ${maxNesting})`);
        }
      }
      
      if (issues.length > 0) {
        console.log(`  Found ${issues.length} potential issues:`);
        issues.forEach(issue => console.log(`    - ${issue}`));
        reviewAreas.push({file, issues});
      } else {
        console.log(`  No obvious issues detected`);
      }
    } catch (e: any) {
      console.log(`  Error reading file: ${e.message}`);
    }
  } else {
    console.log(`  File does not exist`);
  }
});

console.log('\n2. Summary of potential review areas:');
console.log('=====================================');

if (reviewAreas.length > 0) {
  console.log(`Found ${reviewAreas.length} files with potential issues:\n`);
  
  reviewAreas.forEach(area => {
    console.log(`File: ${area.file}`);
    console.log(`Issues (${area.issues.length}):`);
    area.issues.forEach(issue => console.log(`  - ${issue}`));
    console.log('');
  });
  
  // Categorize by priority
  console.log('3. Categorized by priority:');
  console.log('===========================');
  
  const categorized: {[key: string]: Array<{file: string, issue: string}>} = {
    'P0': [], // Critical - security, data loss
    'P1': [], // Major - bugs, performance
    'P2': [], // Minor - code quality
    'P3': []  // Suggestions - improvements
  };
  
  reviewAreas.forEach(area => {
    area.issues.forEach(issue => {
      // Categorize based on keywords in the issue
      if (
        issue.includes('secret') || 
        issue.includes('SQL injection') || 
        issue.includes('auth skip') || 
        issue.includes('unsafe eval')
      ) {
        categorized['P0'].push({file: area.file, issue});
      } else if (
        issue.includes('error handling') || 
        issue.includes('highly nested')
      ) {
        categorized['P1'].push({file: area.file, issue});
      } else if (
        issue.includes('debug statement')
      ) {
        categorized['P2'].push({file: area.file, issue});
      } else {
        categorized['P3'].push({file: area.file, issue});
      }
    });
  });
  
  Object.entries(categorized).forEach(([priority, items]) => {
    if (items.length > 0) {
      console.log(`\n${priority} issues (${items.length}):`);
      items.forEach(item => {
        const relativePath = item.file.replace('/Users/hexa/Desktop/tfp-latest/', '');
        console.log(`  - ${relativePath}: ${item.issue}`);
      });
    }
  });
} else {
  console.log('No obvious issues detected in recently changed files.');
  console.log('However, a thorough review should still be performed to ensure code quality and correctness.');
}

// Look at the TODO and other documentation files
console.log('\n4. Checking documentation files for context:');
console.log('============================================');

const docFiles = [
  '/Users/hexa/Desktop/tfp-latest/TODO.md',
  '/Users/hexa/Desktop/tfp-latest/features.md',
  '/Users/hexa/Desktop/tfp-latest/CTO_REVIEW_REQUIREMENTS_IMPLEMENTATION.md'
];

docFiles.forEach(file => {
  if (fs.existsSync(file)) {
    const content = fs.readFileSync(file, 'utf-8');
    console.log(`\nContent of ${path.basename(file)} (first 300 chars):`);
    console.log(content.substring(0, 300) + (content.length > 300 ? '...' : ''));
  }
});