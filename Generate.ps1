$InstructionsFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "Instructions"
$GeneratedFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "Generated"

$CSVFilePath = Join-Path -Path $InstructionsFolderPath -ChildPath "Instructions.csv"
$Instructions = Import-Csv -Path $CSVFilePath

$OutputJsonPath = Join-Path -Path $GeneratedFolderPath -ChildPath "Instructions.json"

$JsonData = @{
    "github.copilot.chat.codeGeneration.instructions" = New-Object System.Collections.ArrayList
    "github.copilot.chat.testGeneration.instructions" = New-Object System.Collections.ArrayList
}

foreach ($Instruction in $Instructions)
{
    $Text = "For $($Instruction.Language.Trim()) language $($Instruction.Type.Trim().ToLower()) generation, $($Instruction.Instruction.Trim())"

    $JsonNode = if ($Instruction.Type -eq "Code")
    {
        "github.copilot.chat.codeGeneration.instructions"
    }
    elseif ($Instruction.Type -eq "Test")
    {
        "github.copilot.chat.testGeneration.instructions"
    }

    $JsonData.$JsonNode.Add($Text) | Out-Null
}

$JsonData.'github.copilot.chat.codeGeneration.instructions' = $JsonData.'github.copilot.chat.codeGeneration.instructions' | Sort-Object -Unique
$JsonData.'github.copilot.chat.testGeneration.instructions' = $JsonData.'github.copilot.chat.testGeneration.instructions' | Sort-Object -Unique

$JsonData | ConvertTo-Json -Depth 10 -Compress:$false | Set-Content -Path $OutputJsonPath