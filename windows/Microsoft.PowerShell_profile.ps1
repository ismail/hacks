function prompt
{
    $p=Get-Location;
    $p=$p -replace "C:\\Users\\ismail", "~";
    write-host -nonewline -f darkcyan ($env:computername.toLower() + " ");
    write-host -nonewline -f darkyellow $p;
    write-host -nonewline " >";
    return " "
}

function vs-set($arch)
{
	pushd 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build'
	cmd /c "set VSCMD_START_DIR=%CD% && vcvarsall.bat $arch&set" |
	foreach {
  	if ($_ -match "=") {
    		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  	}
	}
	popd
}

function vs32
{
    vs-set x86
}

function vs64
{
    vs-set amd64
}

function activate ( $venv )
{
    . "C:\Users\ismail\py-virtualenvironments\$venv\Scripts\Activate.ps1"
}

$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding

set-psreadlineoption -t parameter darkblue
set-psreadlineoption -t operator darkblue
set-psreadlineoption -t string darkgreen
set-psreadlineoption -BellStyle None
set-psreadlinekeyhandler -Key UpArrow -Function HistorySearchBackward
set-psreadlinekeyhandler -Key DownArrow -Function HistorySearchForward

$win32="i686-x86_64-w64-mingw32"
$win64="x86_64-w64-mingw32"

remove-item alias:curl
