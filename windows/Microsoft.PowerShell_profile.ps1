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
	pushd 'c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
	cmd /c "vcvarsall.bat $arch&set" |
	foreach {
  	if ($_ -match "=") {
    		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  	}
	}
	popd
}

function ps-vs32
{
    vs-set x86
}

function ps-vs64
{
    vs-set amd64
}

$OutputEncoding = New-Object -typename System.Text.UTF8Encoding
[Console]::OutputEncoding = New-Object -typename System.Text.UTF8Encoding

set-psreadlineoption -t parameter darkblue
set-psreadlineoption -t operator darkblue
set-psreadlineoption -t string darkgreen
set-psreadlinekeyhandler -Key UpArrow -Function HistorySearchBackward
set-psreadlinekeyhandler -Key DownArrow -Function HistorySearchForward

$win32="i686-w64-mingw32"
$win64="x86_64-w64-mingw32"
