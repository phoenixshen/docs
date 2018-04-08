####GIT
 - git commit 合并

        git rebase master
        git rebase -i HEAD~2
        squash commit will be merge to last commit

#### openWrt

- patch

        make package/example/{clean,prepare} V=s QUILT=1
        quilt new 010-main_code_fix.patch
        先add文件，然后再进行覆盖
        Quilt edit ×
        quilt refresh
        make package/example/update V=s
        make package/example/{clean,compile} package/index V=s
