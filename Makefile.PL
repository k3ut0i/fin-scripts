use ExtUtils::MakeMaker;

WriteMakefile
  (
   NAME => 'fin_scripts',
   AUTHOR => 'Keutoi <k3tu0isui@gmail.com>',
   VERSION_FROM => 'lib/SBI/XLS.pm',
   MAN1PODS => { 'scripts/db_create.pl' => 'blib/man1/db_create.pl'}
  );
