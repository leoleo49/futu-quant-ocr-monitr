#  pwsh C:\Users\leo50\Desktop\quant-monitor.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Capture the whole screen
$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$FullWidth = $Screen.Width
$FullHeight = $Screen.Height
$Left = $Screen.Left
$Top = $Screen.Top

$ScreenshotPath="D:/QuantMonitorScreenshot.jpg"
$FullScreenshotPath="D:/FullQuantMonitorScreenshot.jpg"

$fullBitmap = New-Object System.Drawing.Bitmap($FullWidth, $FullHeight)
$graphic = [System.Drawing.Graphics]::FromImage($fullBitmap)
$graphic.CopyFromScreen($Left, $Top, 0, 0, $fullBitmap.Size)
$fullBitmap.Save("$FullScreenshotPath", [System.Drawing.Imaging.ImageFormat]::Jpeg)

# Now crop the top-left 25%
$Width = [math]::Round($FullWidth / 2)
$Height = [math]::Round($FullHeight / 2)
$cropRectangle = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)

$croppedBitmap = $fullBitmap.Clone($cropRectangle, $fullBitmap.PixelFormat)

# Convert red pixels to white with a larger range
for ($x = 0; $x -lt $croppedBitmap.Width; $x++) {
    for ($y = 0; $y -lt $croppedBitmap.Height; $y++) {
        $color = $croppedBitmap.GetPixel($x, $y)
        if ($color.R -gt 100 -and $color.G -lt 100 -and $color.B -lt 100) {
            $croppedBitmap.SetPixel($x, $y, [System.Drawing.Color]::White)
        }
    }
}

# Save the cropped and modified image
$jpegEncoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$encoderParameters = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 100L)
$croppedBitmap.Save("$ScreenshotPath", $jpegEncoder, $encoderParameters)

Write-Output "Cropped and modified screenshot saved to: $ScreenshotPath"


# Upload the image using multipart/form-data
$apiUrl = "https://prod-25.japaneast.logic.azure.com:443/workflows/c35900c0947c4c8e9965ee0b7cd97299/triggers/When_a_HTTP_request_is_received/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2FWhen_a_HTTP_request_is_received%2Frun&sv=1.0&sig=YlwvSWCsLnRBVvuDkxRbPrjc6nrGAcOABA2DjabHbjo"

$multipartContent = [System.Net.Http.MultipartFormDataContent]::new()
$multipartFile = "D:/QuantMonitorScreenshot.jpg"
$FileStream = [System.IO.FileStream]::new($multipartFile, [System.IO.FileMode]::Open)
$fileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new("form-data")
$fileHeader.Name = ""
$fileHeader.FileName = "D:/QuantMonitorScreenshot.jpg"
$fileContent = [System.Net.Http.StreamContent]::new($FileStream)
$fileContent.Headers.ContentDisposition = $fileHeader
$multipartContent.Add($fileContent)

$body = $multipartContent


$response = Invoke-RestMethod $apiUrl  -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json