$root = "D:\projects\prompt\app-fe-v2"
$out = Join-Path $root 'full-tree.txt'
if (Test-Path $out) { Remove-Item $out -Force }

# Directory names to exclude everywhere in the tree
$excludedDirNames = @(
    'node_modules',
    '.git',
    'cxx',
    'desugar_graph',
    'dex',
    '.gradle',
    'build',
    '.idea',
    '.dart_tool'
)

function Write-Tree($path, $indent) {
    $items = Get-ChildItem -LiteralPath $path -Force -ErrorAction SilentlyContinue |
        Where-Object { -not ($excludedDirNames -contains $_.Name) } |
        Sort-Object @{Expression={$_.PSIsContainer};Descending=$true}, Name

    foreach ($it in $items) {
        if ($it.PSIsContainer) {
            "$indent- $($it.Name)/" | Out-File -FilePath $out -Append -Encoding utf8
            Write-Tree $it.FullName ("$indent    ")
        } else {
            # Exclude example config files (like *.example, .env.example)
            if ($it.Name -notlike '*.example' -and $it.Name -notlike '*.env*') {
                "$indent- $($it.Name)" | Out-File -FilePath $out -Append -Encoding utf8
            }
        }
    }
}

# First line: project root
"- $(Split-Path $root -Leaf)/" | Out-File -FilePath $out -Encoding utf8
Write-Tree $root ''

Write-Host "Saved tree to: $out"