-- CreateEnum
CREATE TYPE "EstadoBeneficiario" AS ENUM ('ACTIVO', 'INHABILITADO');

-- CreateEnum
CREATE TYPE "EstadoCredencial" AS ENUM ('ACTIVA', 'REVOCADA');

-- CreateEnum
CREATE TYPE "EstadoConsumo" AS ENUM ('REGISTRADO', 'ANULADO');

-- CreateEnum
CREATE TYPE "MetodoIngreso" AS ENUM ('QR_CAMARA', 'LECTOR_USB', 'CODIGO_MANUAL', 'BUSQUEDA_DNI');

-- CreateEnum
CREATE TYPE "MotivoRechazo" AS ENUM ('CODIGO_INEXISTENTE', 'CREDENCIAL_VENCIDA', 'CREDENCIAL_REVOCADA', 'BENEFICIARIO_INHABILITADO', 'VIGENCIA_NO_INICIADA');

-- CreateEnum
CREATE TYPE "RolAdmin" AS ENUM ('ADMIN', 'RRHH', 'CONSULTA');

-- CreateTable
CREATE TABLE "empresas" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "activa" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "empresas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sucursales" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "direccion" TEXT,
    "activa" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sucursales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tipos_descuento" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "porcentaje" DECIMAL(5,2) NOT NULL,
    "descripcion" TEXT,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tipos_descuento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "beneficiarios" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "apellido" TEXT NOT NULL,
    "dni" TEXT NOT NULL,
    "email" TEXT,
    "empresaId" INTEGER NOT NULL,
    "tipoDescuentoId" INTEGER NOT NULL,
    "estado" "EstadoBeneficiario" NOT NULL DEFAULT 'ACTIVO',
    "fechaAlta" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "fechaBaja" TIMESTAMP(3),
    "motivoBaja" TEXT,
    "actualizadoEn" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "beneficiarios_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "credenciales" (
    "id" SERIAL NOT NULL,
    "beneficiarioId" INTEGER NOT NULL,
    "token" TEXT NOT NULL,
    "codigoCorto" TEXT NOT NULL,
    "vigenciaDesde" TIMESTAMP(3) NOT NULL,
    "vigenciaHasta" TIMESTAMP(3) NOT NULL,
    "estado" "EstadoCredencial" NOT NULL DEFAULT 'ACTIVA',
    "emitidaEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "emitidaPorId" INTEGER NOT NULL,
    "revocadaEn" TIMESTAMP(3),
    "revocadaPorId" INTEGER,
    "motivoRevocacion" TEXT,

    CONSTRAINT "credenciales_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usuarios_admin" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "rol" "RolAdmin" NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "debeCambiarPw" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ultimoAcceso" TIMESTAMP(3),

    CONSTRAINT "usuarios_admin_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operadores" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "apellido" TEXT NOT NULL,
    "pinHash" TEXT NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "operadores_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "operador_sucursal" (
    "operadorId" INTEGER NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "asignadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "operador_sucursal_pkey" PRIMARY KEY ("operadorId","sucursalId")
);

-- CreateTable
CREATE TABLE "dispositivos" (
    "id" SERIAL NOT NULL,
    "nombre" TEXT NOT NULL,
    "sucursalId" INTEGER NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "activo" BOOLEAN NOT NULL DEFAULT true,
    "vinculadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "vinculadoPorId" INTEGER NOT NULL,
    "ultimoUso" TIMESTAMP(3),

    CONSTRAINT "dispositivos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consumos" (
    "id" SERIAL NOT NULL,
    "nroOperacion" SERIAL NOT NULL,
    "fechaHora" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sucursalId" INTEGER NOT NULL,
    "dispositivoId" INTEGER NOT NULL,
    "beneficiarioId" INTEGER NOT NULL,
    "credencialId" INTEGER,
    "operadorId" INTEGER NOT NULL,
    "metodoIngreso" "MetodoIngreso" NOT NULL,
    "porcentajeAplicado" DECIMAL(5,2) NOT NULL,
    "nroTicket" TEXT,
    "montoBruto" DECIMAL(12,2),
    "montoDescuento" DECIMAL(12,2),
    "observaciones" TEXT,
    "estado" "EstadoConsumo" NOT NULL DEFAULT 'REGISTRADO',
    "anuladoEn" TIMESTAMP(3),
    "anuladoPorId" INTEGER,
    "motivoAnulacion" TEXT,

    CONSTRAINT "consumos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "validaciones_rechazadas" (
    "id" SERIAL NOT NULL,
    "fechaHora" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sucursalId" INTEGER NOT NULL,
    "operadorId" INTEGER,
    "codigoIngresado" TEXT NOT NULL,
    "metodoIngreso" "MetodoIngreso" NOT NULL,
    "motivo" "MotivoRechazo" NOT NULL,

    CONSTRAINT "validaciones_rechazadas_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auditoria" (
    "id" SERIAL NOT NULL,
    "fechaHora" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "usuarioId" INTEGER NOT NULL,
    "accion" TEXT NOT NULL,
    "entidad" TEXT NOT NULL,
    "entidadId" INTEGER NOT NULL,
    "datosAntes" JSONB,
    "datosDespues" JSONB,
    "ip" TEXT,

    CONSTRAINT "auditoria_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "empresas_nombre_key" ON "empresas"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "sucursales_nombre_key" ON "sucursales"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "tipos_descuento_nombre_key" ON "tipos_descuento"("nombre");

-- CreateIndex
CREATE UNIQUE INDEX "beneficiarios_dni_key" ON "beneficiarios"("dni");

-- CreateIndex
CREATE INDEX "beneficiarios_apellido_nombre_idx" ON "beneficiarios"("apellido", "nombre");

-- CreateIndex
CREATE UNIQUE INDEX "credenciales_token_key" ON "credenciales"("token");

-- CreateIndex
CREATE UNIQUE INDEX "credenciales_codigoCorto_key" ON "credenciales"("codigoCorto");

-- CreateIndex
CREATE INDEX "credenciales_beneficiarioId_idx" ON "credenciales"("beneficiarioId");

-- CreateIndex
CREATE UNIQUE INDEX "usuarios_admin_email_key" ON "usuarios_admin"("email");

-- CreateIndex
CREATE UNIQUE INDEX "dispositivos_tokenHash_key" ON "dispositivos"("tokenHash");

-- CreateIndex
CREATE UNIQUE INDEX "consumos_nroOperacion_key" ON "consumos"("nroOperacion");

-- CreateIndex
CREATE INDEX "consumos_beneficiarioId_fechaHora_idx" ON "consumos"("beneficiarioId", "fechaHora");

-- CreateIndex
CREATE INDEX "consumos_sucursalId_fechaHora_idx" ON "consumos"("sucursalId", "fechaHora");

-- CreateIndex
CREATE INDEX "validaciones_rechazadas_sucursalId_fechaHora_idx" ON "validaciones_rechazadas"("sucursalId", "fechaHora");

-- CreateIndex
CREATE INDEX "auditoria_entidad_entidadId_idx" ON "auditoria"("entidad", "entidadId");

-- CreateIndex
CREATE INDEX "auditoria_fechaHora_idx" ON "auditoria"("fechaHora");

-- AddForeignKey
ALTER TABLE "beneficiarios" ADD CONSTRAINT "beneficiarios_empresaId_fkey" FOREIGN KEY ("empresaId") REFERENCES "empresas"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "beneficiarios" ADD CONSTRAINT "beneficiarios_tipoDescuentoId_fkey" FOREIGN KEY ("tipoDescuentoId") REFERENCES "tipos_descuento"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credenciales" ADD CONSTRAINT "credenciales_beneficiarioId_fkey" FOREIGN KEY ("beneficiarioId") REFERENCES "beneficiarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credenciales" ADD CONSTRAINT "credenciales_emitidaPorId_fkey" FOREIGN KEY ("emitidaPorId") REFERENCES "usuarios_admin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credenciales" ADD CONSTRAINT "credenciales_revocadaPorId_fkey" FOREIGN KEY ("revocadaPorId") REFERENCES "usuarios_admin"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operador_sucursal" ADD CONSTRAINT "operador_sucursal_operadorId_fkey" FOREIGN KEY ("operadorId") REFERENCES "operadores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "operador_sucursal" ADD CONSTRAINT "operador_sucursal_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dispositivos" ADD CONSTRAINT "dispositivos_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dispositivos" ADD CONSTRAINT "dispositivos_vinculadoPorId_fkey" FOREIGN KEY ("vinculadoPorId") REFERENCES "usuarios_admin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_dispositivoId_fkey" FOREIGN KEY ("dispositivoId") REFERENCES "dispositivos"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_beneficiarioId_fkey" FOREIGN KEY ("beneficiarioId") REFERENCES "beneficiarios"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_credencialId_fkey" FOREIGN KEY ("credencialId") REFERENCES "credenciales"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_operadorId_fkey" FOREIGN KEY ("operadorId") REFERENCES "operadores"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consumos" ADD CONSTRAINT "consumos_anuladoPorId_fkey" FOREIGN KEY ("anuladoPorId") REFERENCES "usuarios_admin"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "validaciones_rechazadas" ADD CONSTRAINT "validaciones_rechazadas_sucursalId_fkey" FOREIGN KEY ("sucursalId") REFERENCES "sucursales"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "validaciones_rechazadas" ADD CONSTRAINT "validaciones_rechazadas_operadorId_fkey" FOREIGN KEY ("operadorId") REFERENCES "operadores"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auditoria" ADD CONSTRAINT "auditoria_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "usuarios_admin"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
