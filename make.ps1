#!/usr/bin/env pwsh

# make.ps1 - Wrapper pour exécuter les commandes Terraform via PowerShell
# Simule les targets du Makefile sur Windows

Param(
    [string]$Target = "help",
    [string[]]$AdditionalArgs = @()
)

function Show-Help {
    Write-Host "============ MENU ============" -ForegroundColor Cyan
    Write-Host "tf.init              Initialiser Terraform" -ForegroundColor Cyan
    Write-Host "help                 Afficher ce message" -ForegroundColor Cyan
    Write-Host "============ END OF MENU ============" -ForegroundColor Cyan
}

function Invoke-TerraformInit {
    Write-Host "► terraform init" -ForegroundColor Green
    terraform init
    if ($LASTEXITCODE -ne 0) { exit 1 }
}

switch ($Target) {
    "help" { Show-Help }
    "tf.init" { Invoke-TerraformInit }
    default { 
        Write-Host "❌ Target inconnue: $Target" -ForegroundColor Red
        Show-Help
        exit 1
    }
}
