Param($dataset_dir, $result_dir, $sevenzip_path)

$swatch = New-Object System.Diagnostics.Stopwatch

foreach ($orig in [System.IO.Directory]::GetFiles($dataset_dir, '*')) {
	$fname = [System.IO.Path]::GetFilename($orig);

	if ($fname.startsWith('.')) { continue; }

	$resfile = [System.IO.Path]::Combine($result_dir, $fname + '.csv')

	$orig_size = (Get-Item $orig).Length

	# 7z
	# -ms=off -mf=off -mhe=off -mmt=on -m0=LZMA
	foreach ($level in @(0, 1, 3, 5, 7, 9)) {
		for ($compression_mode = 0; $compression_mode -lt 2; $compression_mode++) {
			foreach ($mf in @('bt2', 'bt3', 'bt4', 'hc4')) {
				$7zargs = "-mx=$level", "-ms=off", "-mf=off", "-mhe=off", "-mmt=on", ("-m0=LZMA:a=$compression_mode" + ":mf=$mf")

				$swatch.Reset()
				$swatch.Start()
				& "$sevenzip_path" a temp.7z $7zargs "$orig"
				if ($? -eq $false) { exit }
				$swatch.Stop()

				$csize = (Get-Item temp.7z).Length
				Remove-Item temp.7z
				$ctime = $swatch.Elapsed.TotalMilliseconds / 1000.0
				$ratio = $csize / $orig_size * 100.0

				$csv_data = @( [PSCustomObject]@{
						Application       = "7-Zip 7z (LZMA)";
						Version           = "N/A";
						Args              = [string]::Join(' ', $7zargs);
						Ratio             = $ratio;
						OriginalSize      = $orig_size;
						CompressedSize    = $csize;
						CompressionTime   = $ctime;
						DecompressionTime = '';
					} )

				$csv_data | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File -FilePath $resfile -Append -Encoding utf8
			}
		}
	}

	# -ms=off -mf=off -mhe=off -mmt=on -m0=LZMA2
	foreach ($level in @(0, 1, 3, 5, 7, 9)) {
		for ($compression_mode = 0; $compression_mode -lt 2; $compression_mode++) {
			foreach ($mf in @('bt2', 'bt3', 'bt4', 'hc4')) {
				$7zargs = "-mx=$level", "-ms=off", "-mf=off", "-mhe=off", "-mmt=on", ("-m0=LZMA2:a=$compression_mode" + ":mf=$mf")

				$swatch.Reset()
				$swatch.Start()
				& "$sevenzip_path" a temp.7z $7zargs "$orig"
				if ($? -eq $false) { exit }
				$swatch.Stop()

				$csize = (Get-Item temp.7z).Length
				Remove-Item temp.7z
				$ctime = $swatch.Elapsed.TotalMilliseconds / 1000.0
				$ratio = $csize / $orig_size * 100.0

				$csv_data = @( [PSCustomObject]@{
						Application       = "7-Zip 7z (LZMA2)";
						Version           = "N/A";
						Args              = [string]::Join(' ', $7zargs);
						Ratio             = $ratio;
						OriginalSize      = $orig_size;
						CompressedSize    = $csize;
						CompressionTime   = $ctime;
						DecompressionTime = '';
					} )

				$csv_data | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File -FilePath $resfile -Append -Encoding utf8
			}
		}
	}

	# -ms=off -mf=off -mhe=off -mmt=on -m0=PPMd
	foreach ($level in @(0, 1, 3, 5, 7, 9)) {
		$7zargs = "-mx=$level", "-ms=off", "-mf=off", "-mhe=off", "-mmt=on", ("-m0=PPMd")

		$swatch.Reset()
		$swatch.Start()
		& "$sevenzip_path" a temp.7z $7zargs "$orig"
		if ($? -eq $false) { exit }
		$swatch.Stop()

		$csize = (Get-Item temp.7z).Length
		Remove-Item temp.7z
		$ctime = $swatch.Elapsed.TotalMilliseconds / 1000.0
		$ratio = $csize / $orig_size * 100.0

		$csv_data = @( [PSCustomObject]@{
				Application       = "7-Zip 7z (PPMd)";
				Version           = "N/A";
				Args              = [string]::Join(' ', $7zargs);
				Ratio             = $ratio;
				OriginalSize      = $orig_size;
				CompressedSize    = $csize;
				CompressionTime   = $ctime;
				DecompressionTime = '';
			} )

		$csv_data | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File -FilePath $resfile -Append -Encoding utf8
	}

	# -mmt=on
	foreach ($level in @(1, 9))
	{
		foreach ($num_fast_byte in @(32, 64, 128, 192, 256, 257))
		{
			foreach ($num_passes in @(1, 2, 3, 5, 7, 10, 13, 15))
			{
				foreach($method in @('Deflate', 'Deflate64'))
				{
					$7zargs = "-tzip", "-mx=$level", "-mmt=on", "-mfb=$num_fast_byte", "-mpass=$num_passes", "-mm=$method"
			
					Write-Host $7zargs
	
					$swatch.Reset()
					$swatch.Start()
					& "$sevenzip_path" a temp.zip $7zargs "$orig"
					if ($? -eq $false) { exit }
					$swatch.Stop()
			
					$csize = (Get-Item temp.zip).Length
					Remove-Item temp.zip
					$ctime = $swatch.Elapsed.TotalMilliseconds / 1000.0
					$ratio = $csize / $orig_size * 100.0
			
					$csv_data = @( [PSCustomObject]@{
							Application       = "7-Zip Zip ($method)";
							Version           = "N/A";
							Args              = [string]::Join(' ', $7zargs);
							Ratio             = $ratio;
							OriginalSize      = $orig_size;
							CompressedSize    = $csize;
							CompressionTime   = $ctime;
							DecompressionTime = '';
						} )
			
					$csv_data | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Out-File -FilePath $resfile -Append -Encoding utf8
				}
			}
		}
	}
}