import 'dart:io';

void main() async {
  print('--- Agente Interactivo para GitHub ---');

  // 1. Preguntar por el link del repositorio
  stdout.write('Introduce el link del nuevo repositorio (https://github.com/JesusCampoya0452/Ejemplo-crud-Lavanderia-6j-abril-2026.git): ');
  String? repoLink = stdin.readLineSync();
  if (repoLink == null || repoLink.isEmpty) {
    print('Error: El link del repositorio no puede estar vacío.');
    return;
  }

  // 2. Preguntar por el mensaje del commit
  stdout.write('Introduce el mensaje del commit: ');
  String? commitMessage = stdin.readLineSync();
  if (commitMessage == null || commitMessage.isEmpty) {
    commitMessage = 'Primer commit'; // Default if empty
  }

  // 3. Preguntar por el nombre de la rama (main por default)
  stdout.write('Nombre de la rama (presiona Enter para "main"): ');
  String? branchName = stdin.readLineSync();
  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
  }

  print('\nIniciando proceso de envío a GitHub...\n');

  try {
    // Verificar si git ya está inicializado
    bool gitInitialized = Directory('.git').existsSync();

    if (!gitInitialized) {
      await runCommand('git', ['init']);
    }

    await runCommand('git', ['add', '.']);
    await runCommand('git', ['commit', '-m', commitMessage]);
    await runCommand('git', ['branch', '-M', branchName]);

    // Intentar agregar el remote (puede fallar si ya existe)
    try {
      await runCommand('git', ['remote', 'add', 'origin', repoLink]);
    } catch (e) {
      print('Aviso: El remote "origin" ya existe o no se pudo agregar. Intentando actualizar...');
      await runCommand('git', ['remote', 'set-url', 'origin', repoLink]);
    }

    print('Subiendo archivos a $repoLink rama: $branchName...');
    await runCommand('git', ['push', '-u', 'origin', branchName]);

    print('\n¡Éxito! Proyecto enviado correctamente a GitHub.');
  } catch (e) {
    print('\nError durante el proceso: $e');
  }
}

Future<void> runCommand(String command, List<String> arguments) async {
  final result = await Process.run(command, arguments);
  if (result.exitCode != 0) {
    throw Exception('El comando "$command ${arguments.join(' ')}" falló.\nError: ${result.stderr}');
  }
  print('Ejecutado: $command ${arguments.join(' ')}');
}
