export function ConsoleLog(message, log = true) {
  if (log) {
    console.log(`[ APP LOG ]: ${message}`);
  }
}

export function ConsoleError(message, log = true) {
  if (log) {
    console.Error(`[ APP ERROR ]: ${message}`);
  }
}

export function Logger(constructor) {
  console.log(`[ RUNNING ]: ${constructor}`);
}