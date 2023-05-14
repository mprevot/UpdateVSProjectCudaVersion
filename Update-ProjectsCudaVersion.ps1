$from = "11.8"
$to = "12.1"

function ToColor($color) {
	process { Write-Host $_ -ForegroundColor $color }
}

function CleanBackups($commit) {
	"cleaning from _.vcxproj" | ToColor "yellow"
	$files = Get-ChildItem -recurse *_.vcxproj
	$count = ($files | Measure-Object).Count
	"found $count files" | ToColor "yellow"
	if($commit) {
		Get-ChildItem -recurse *_.vcxproj | Remove-Item
	}
	else {
		Get-ChildItem -recurse *_.vcxproj | Remove-Item -whatif
	}
}

function UpdateCuda($commit) {
	$projfiles = Get-ChildItem -Recurse *.vcxproj
	foreach($f in $projfiles) {
		$hascuda = $f | Select-String  -pattern "CUDA 1"
		if($hascuda) {
			"$($f.name) has CUDA" | ToColor "yellow"
			$hasfrom = $hascuda | Select-String -pattern "CUDA $from"
			if(-not $hasfrom) {
				"$($f.name) has not $from (and won't be edited)" | ToColor "red"
				"$hascuda" | ToColor "magenta"
			}
			if($hasfrom) {
				$newcontent = (Get-Content -path $f.fullname -Raw) -replace ('CUDA ' + $from),('CUDA '+ $to)
				$newfile = $f.basename + "_" + $f.extension
				$base = $f.directory
				if($commit) {
					"writing $($f.name)" | ToColor "yellow"
					Copy-Item $f.fullname "$base/$newfile"
				}
				"new filename: $newfile with cuda $to"
				if($commit) {
					"writing $($f.name) with cuda $to" | ToColor "yellow"
					"$newcontent" | Set-Content -Path $f.fullname
				}
			}
		}
	}
}

CleanBackups 1
UpdateCuda 1