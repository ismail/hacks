function prompt {
    $p = Get-Location;
    $p = $p -replace "C:\\Users\\ismail", "~";
    write-host -nonewline -f darkcyan ($env:computername.toLower() + " ");
    write-host -nonewline -f darkyellow $p;
    write-host -nonewline " >";
    return " "
}

function ssh-forget {
    ssh -oStrictHostKeyChecking=accept-new -oUserKnownHostsFile=nul $args
}
function vs-set($arch) {
    pushd 'C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build'
    cmd /c "set VSCMD_START_DIR=%CD% && vcvarsall.bat $arch&set" |
        foreach {
        if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
        }
    }
    popd
}

function vs32 {
    vs-set x86
}

function vs64 {
    vs-set amd64
}

function which ($exe) {
    ($Env:Path).Split(";") | Get-ChildItem -filter $exe
}

[console]::OutputEncoding = [Text.Encoding]::Utf8
chcp 65001 >$nul
$env:LC_ALL = 'C.UTF-8'

set-psreadlineoption -BellStyle None
set-psreadlinekeyhandler -Key UpArrow -Function HistorySearchBackward
set-psreadlinekeyhandler -Key DownArrow -Function HistorySearchForward
set-psreadlineoption -Colors @{Parameter = 'darkblue'; Operator = 'darkblue'; String = 'darkgreen'}

remove-item alias:curl

. _rg.ps1
