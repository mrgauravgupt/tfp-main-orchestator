import * as fs from 'fs';
import * as path from 'path';
import { execSync } from 'child_process';

/**
 * Script to find changes in the TFP repository
 */

console.log('=== Looking for changes in the TFP repository ===\n');

const workspaceRoot = '/Users/hexa/Desktop/tfp-latest';

try {
  // Check if this is a git repository
  console.log('1. Checking Git Status:');
  console.log('=====================');
  
  const gitDir = path.join(workspaceRoot, '.git');
  if (fs.existsSync(gitDir)) {
    console.log('Repository is a git repo');
    
    // Get current branch
    try {
      const currentBranch = execSync('git branch --show-current', { cwd: workspaceRoot, encoding: 'utf-8' }).trim();
      console.log(`Current branch: ${currentBranch}`);
    } catch (e: any) {
      console.log("Could not determine current branch:", e.message);
    }
    
    // Check for uncommitted changes
    try {
      const statusResult = execSync('git status --porcelain', { cwd: workspaceRoot, encoding: 'utf-8' });
      if (statusResult.trim()) {
        console.log('Uncommitted changes:');
        console.log(statusResult);
      } else {
        console.log('No uncommitted changes');
      }
    } catch (e: any) {
      console.log('Error checking git status:', e.message);
    }
    
    // Check for recent commits
    try {
      const recentCommits = execSync('git log --oneline -10', { cwd: workspaceRoot, encoding: 'utf-8' });
      console.log('\nRecent commits:');
      console.log(recentCommits);
    } catch (e: any) {
      console.log('Error getting recent commits:', e.message);
    }
  } else {
    console.log('Not a git repository');
  }
} catch (e: any) {
  console.log('Git operations failed:', e.message);
}

// Look for diff-like files in the workspace
console.log('\n2. Looking for diff-like files:');
console.log('===============================');

const searchExtensions = ['.diff', '.patch', '.log'];
const foundFiles: string[] = [];

function scanDirectory(dir: string) {
  const items = fs.readdirSync(dir);
  
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    
    if (stat.isDirectory()) {
      // Skip node_modules and other large directories
      if (item !== 'node_modules' && !item.startsWith('.')) {
        scanDirectory(fullPath);
      }
    } else {
      const ext = path.extname(item);
      if (searchExtensions.includes(ext.toLowerCase())) {
        foundFiles.push(fullPath);
      }
      // Look for files that might contain diff content
      else if (item.includes('diff') || item.includes('change') || item.includes('log')) {
        foundFiles.push(fullPath);
      }
    }
  }
}

scanDirectory(workspaceRoot);

if (foundFiles.length > 0) {
  console.log('Potentially relevant files:');
  foundFiles.forEach(file => console.log(`  - ${file}`));
} else {
  console.log('No diff-like files found');
}

// Look for recently modified files
console.log('\n3. Recently modified files:');
console.log('============================');

try {
  // Find files modified in the last day
  const modifiedFiles = execSync(
    `find . -type f -mtime -1 -not -path "./node_modules/*" -not -path "./.*" | head -20`, 
    { cwd: workspaceRoot, encoding: 'utf-8' }
  );
  
  if (modifiedFiles.trim()) {
    console.log('Files modified in the last 24 hours:');
    console.log(modifiedFiles);
  } else {
    console.log('No files modified in the last 24 hours');
  }
} catch (e: any) {
  console.log('Error finding recently modified files:', e.message);
}

// Look for any temporary change files that might have been created
console.log('\n4. Temporary change files:');
console.log('===========================');

const tempChangePatterns = [
  'tmp/',
  'changeset',
  'changelog',
  'update',
  'migration'
];

tempChangePatterns.forEach(pattern => {
  const items = fs.readdirSync(workspaceRoot);
  const matches = items.filter(item => 
    item.toLowerCase().includes(pattern) ||
    fs.statSync(path.join(workspaceRoot, item)).isDirectory() && 
    item.toLowerCase().includes(pattern)
  );
  
  if (matches.length > 0) {
    console.log(`${pattern} related items:`);
    matches.forEach(match => console.log(`  - ${match}`));
  }
});

// Look specifically in the tfp-workspace for potential changes
console.log('\n5. Recent changes in tfp-workspace apps:');
console.log('========================================');

const tfpWorkspacePath = path.join(workspaceRoot, 'tfp-workspace');
const appsPath = path.join(tfpWorkspacePath, 'apps');

if (fs.existsSync(appsPath)) {
  const apps = fs.readdirSync(appsPath);
  
  apps.forEach(app => {
    const appPath = path.join(appsPath, app);
    const appStat = fs.statSync(appPath);
    
    if (appStat.isDirectory()) {
      console.log(`\n${app} app:`);
      
      // Check if there are any recently changed files in the app
      try {
        const appChanges = execSync(
          `find ${appPath}/src -type f -newer ${appPath}/package.json 2>/dev/null | head -10`,
          { encoding: 'utf-8' }
        );
        
        if (appChanges.trim()) {
          console.log('Recently changed source files:');
          console.log(appChanges.split('\n').filter(line => line.trim()).slice(0, 10).join('\n'));
        } else {
          console.log('No source files newer than package.json');
        }
      } catch (e: any) {
        console.log('Could not check app changes:', e.message);
      }
    }
  });
}

console.log('\n6. Potential change indicators in top-level files:');
console.log('==================================================');

// Check some specific files that might contain change information
const potentialChangeFiles = [
  'TODO.md',
  'CTO_REVIEW_REQUIREMENTS_IMPLEMENTATION.md',
  'codex.md',
  'features.md'
];

potentialChangeFiles.forEach(file => {
  const filePath = path.join(workspaceRoot, file);
  if (fs.existsSync(filePath)) {
    const stats = fs.statSync(filePath);
    const modTime = new Date(stats.mtime);
    const now = new Date();
    const hoursDiff = Math.floor((now.getTime() - modTime.getTime()) / (1000 * 60 * 60));
    
    console.log(`${file}: Last modified ${hoursDiff} hours ago`);
    
    // Show a preview of the file content if it's not too large
    const content = fs.readFileSync(filePath, 'utf-8');
    if (content.length < 2000) { // Less than 2000 chars
      console.log('Content preview:');
      console.log(content.substring(0, 500) + (content.length > 500 ? '...' : ''));
      console.log('');
    }
  }
});