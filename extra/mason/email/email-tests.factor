IN: mason.email.tests
USING: mason.email mason.common mason.config namespaces tools.test ;

[ "mason on linux-x86-64: error" ] [
    [
        "linux" target-os set
        "x86.64" target-cpu set
        status-error status set
        subject prefix-subject
    ] with-scope
] unit-test
