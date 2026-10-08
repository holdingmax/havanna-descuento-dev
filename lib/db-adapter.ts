import { PrismaPg } from "@prisma/adapter-pg";

// Adapter de Postgres compartido por la app (lib/prisma.ts) y el seed.
//
// SSL se controla con DATABASE_SSL:
//  - "true": la External URL de Render exige SSL cuando te conectás desde afuera
//    (tu PC, migraciones, seed).
//  - ausente o "false": la Internal URL de Render (desde un servicio dentro de
//    Render) no lo necesita.
// rejectUnauthorized: false acepta el certificado de Render sin validar la cadena.
export function createPgAdapter() {
  return new PrismaPg({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DATABASE_SSL === "true" ? { rejectUnauthorized: false } : undefined,
  });
}
