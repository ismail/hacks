function prompt
{
    $p=Get-Location;
    $p=$p -replace "C:\\Users\\ismail", "~";
    write-host -nonewline -f darkcyan ($env:computername.toLower() + " ");
    write-host -nonewline -f darkyellow $p;
    write-host -nonewline " >";
    return " "
}

function ps-vs32
{
	pushd 'c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
	cmd /c "vcvarsall.bat x86&set" |
	foreach {
  	if ($_ -match "=") {
    		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  	}
	}
	popd
}

function ps-vs64
{
	pushd 'c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
	cmd /c "vcvarsall.bat amd64&set" |
	foreach {
  	if ($_ -match "=") {
    		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  	}
	}
	popd
}

set-psreadlineoption -t parameter darkblue
set-psreadlineoption -t operator darkblue
set-psreadlineoption -t string darkgreen