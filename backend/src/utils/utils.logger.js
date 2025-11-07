export function ConsoleLog(message, log = true) {
  if (log) {
    console.log(`[ LOG ]: ${message}`);
  }
}

export function ConsoleError(message, log = true) {
  if (log) {
    console.error(`[ ERROR ]: ${message}`);
  }
}

export function Logger(constructor) {
  console.log(`[ RUNNING ]: ${constructor}`);
}