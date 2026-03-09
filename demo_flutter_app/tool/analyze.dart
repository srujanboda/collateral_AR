import 'dart:io';

void main() async {
  var result = await Process.run('dart', [
    'analyze',
    '--format=machine',
  ], runInShell: true);
  var out = result.stdout.toString();
  var err = result.stderr.toString();
  stdout.writeln(out.trim());
  stderr.writeln(err.trim());
}
