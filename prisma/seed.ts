import "dotenv/config";
import { randomInt } from "node:crypto";
import bcrypt from "bcryptjs";
import { PrismaClient } from "../generated/prisma/client";
import { createPgAdapter } from "../lib/db-adapter";

const prisma = new PrismaClient({ adapter: createPgAdapter() });

const ADMIN_EMAIL = process.env.SEED_ADMIN_EMAIL ?? "araoz.leticia@gmail.com";
// Sin caracteres ambiguos (O/0, I/1/l).
const ALFABETO = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789";

function passwordTemporal(largo = 16) {
  return Array.from({ length: largo }, () => ALFABETO[randomInt(ALFABETO.length)]).join("");
}

async function main() {
  let tempPw: string | null = null;

  const existente = await prisma.usuarioAdmin.findUnique({ where: { email: ADMIN_EMAIL } });
  if (!existente) {
    tempPw = passwordTemporal();
    await prisma.usuarioAdmin.create({
      data: {
        nombre: "Administrador",
        email: ADMIN_EMAIL,
        passwordHash: await bcrypt.hash(tempPw, 12),
        rol: "ADMIN",
        debeCambiarPw: true,
      },
    });
  }

  for (const nombre of ["Holding", "Correo Flash", "Havanna"]) {
    await prisma.empresa.upsert({ where: { nombre }, update: {}, create: { nombre } });
  }

  for (const porcentaje of [10, 15, 20]) {
    const nombre = `Descuento ${porcentaje}%`;
    await prisma.tipoDescuento.upsert({
      where: { nombre },
      update: {},
      create: { nombre, porcentaje },
    });
  }

  console.log("Seed OK");
  console.log(`Empresas: ${await prisma.empresa.count()}`);
  console.log(`Tipos de descuento: ${await prisma.tipoDescuento.count()}`);
  if (tempPw) {
    console.log(`\nAdmin creado: ${ADMIN_EMAIL}`);
    console.log(`Contraseña temporal: ${tempPw}`);
  } else {
    console.log(`\nEl admin ${ADMIN_EMAIL} ya existía: no se modificó su contraseña.`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
