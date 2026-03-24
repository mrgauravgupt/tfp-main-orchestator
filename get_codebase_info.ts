import * as fs from 'fs';
import * as path from 'path';

/**
 * Script to gather information about the TFP codebase
 */
console.log('=== TFP Codebase Information ===\n');

// Get basic stats about the workspace
const workspaceRoot = '/Users/hexa/Desktop/tfp-latest';

console.log('1. Workspace Structure:');
console.log('========================');
console.log(`Workspace Root: ${workspaceRoot}\n`);

// Read top-level directories and files
const topLevelItems = fs.readdirSync(workspaceRoot);

console.log('Top-level directories:');
topLevelItems
  .filter(item => fs.statSync(path.join(workspaceRoot, item)).isDirectory())
  .forEach(dir => console.log(`  - ${dir}`));

console.log('\nTop-level files:');
topLevelItems
  .filter(item => fs.statSync(path.join(workspaceRoot, item)).isFile())
  .forEach(file => console.log(`  - ${file}`));

// Analyze the tfp-workspace app structure
const tfpWorkspacePath = path.join(workspaceRoot, 'tfp-workspace');
if (fs.existsSync(tfpWorkspacePath)) {
  console.log('\n\n2. TFPS Workspace Details:');
  console.log('===========================');
  
  const appsPath = path.join(tfpWorkspacePath, 'apps');
  if (fs.existsSync(appsPath)) {
    console.log('Apps in workspace:');
    const apps = fs.readdirSync(appsPath);
    apps.forEach(app => {
      console.log(`  - ${app}`);
      
      // Show structure of each app
      const appPath = path.join(appsPath, app);
      const appStats = fs.statSync(appPath);
      if (appStats.isDirectory()) {
        console.log(`    Files/Directories in ${app}:`);
        const appItems = fs.readdirSync(appPath);
        appItems.forEach(item => {
          console.log(`      - ${item}`);
        });
        
        // Look at src directory if it exists
        const srcPath = path.join(appPath, 'src');
        if (fs.existsSync(srcPath)) {
          console.log(`    src directory structure:`);
          const srcItems = fs.readdirSync(srcPath);
          srcItems.forEach(item => {
            console.log(`      - ${item}`);
          });
        }
      }
    });
  }

  // Check packages
  const packagesPath = path.join(tfpWorkspacePath, 'packages');
  if (fs.existsSync(packagesPath)) {
    console.log('\nPackages:');
    const packages = fs.readdirSync(packagesPath);
    packages.forEach(pkg => {
      console.log(`  - ${pkg}`);
      
      const pkgPath = path.join(packagesPath, pkg);
      const pkgStats = fs.statSync(pkgPath);
      if (pkgStats.isDirectory()) {
        console.log(`    Files/Directories in ${pkg}:`);
        const pkgItems = fs.readdirSync(pkgPath);
        pkgItems.forEach(item => {
          console.log(`      - ${item}`);
        });
      }
    });
  }
}

// Check for any diff files or recent changes
console.log('\n\n3. Potential Change Files:');
console.log('==========================');
const diffIndicators = ['.git', 'package.json', 'pnpm-lock.yaml'];
diffIndicators.forEach(indicator => {
  if (fs.existsSync(path.join(workspaceRoot, indicator))) {
    console.log(`Found: ${indicator}`);
  }
});

// Check for test files
const testsPath = path.join(tfpWorkspacePath, 'tests', 'e2e');
if (fs.existsSync(testsPath)) {
  console.log('\n\n4. Test Files:');
  console.log('==============');
  const testFiles = fs.readdirSync(testsPath);
  testFiles.forEach(file => {
    console.log(`  - ${file}`);
  });
}

// Check for mockups
const mockupsPath = path.join(workspaceRoot, 'mockups');
if (fs.existsSync(mockupsPath)) {
  console.log('\n\n5. Mockup Files:');
  console.log('================');
  const mockupFiles = fs.readdirSync(mockupsPath);
  console.log(`Total mockup files: ${mockupFiles.length}`);
  // Show first 10 mockup files
  mockupFiles.slice(0, 10).forEach(file => {
    console.log(`  - ${file}`);
  });
  if (mockupFiles.length > 10) {
    console.log(`  ... and ${mockupFiles.length - 10} more`);
  }
}

console.log('\n\n6. Temporary Directories:');
console.log('=========================');
['tmp', 'audit-shots'].forEach(dir => {
  const dirPath = path.join(workspaceRoot, dir);
  if (fs.existsSync(dirPath)) {
    const items = fs.readdirSync(dirPath);
    console.log(`${dir} contains ${items.length} items`);
    
    if (dir === 'audit-shots' && items.length > 0) {
      console.log('Sample audit-shot directories:');
      items.slice(0, 3).forEach(item => {
        console.log(`  - ${item}`);
      });
    }
  }
});