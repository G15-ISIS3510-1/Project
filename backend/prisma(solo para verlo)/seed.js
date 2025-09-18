const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed de la base de datos de Car Sharing...');

  // Limpiar base de datos
  await prisma.payment.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.vehicleAvailability.deleteMany();
  await prisma.pricing.deleteMany();
  await prisma.vehicle.deleteMany();
  await prisma.insurancePlan.deleteMany();
  await prisma.user.deleteMany();

  console.log('🧹 Base de datos limpiada');

  // Crear usuarios de prueba
  const hashedPassword = await bcrypt.hash('password123', 10);

  const hostUser = await prisma.user.create({
    data: {
      user_id: 'host_001',
      role: 'host',
      name: 'Juan Pérez',
      email: 'host@example.com',
      password: hashedPassword,
      phone: '+1234567890',
      driver_license_status: 'verified',
      status: 'active'
    }
  });

  const renterUser = await prisma.user.create({
    data: {
      user_id: 'renter_001',
      role: 'renter',
      name: 'María García',
      email: 'renter@example.com',
      password: hashedPassword,
      phone: '+0987654321',
      driver_license_status: 'verified',
      status: 'active'
    }
  });

  const bothUser = await prisma.user.create({
    data: {
      user_id: 'both_001',
      role: 'both',
      name: 'Carlos López',
      email: 'both@example.com',
      password: hashedPassword,
      phone: '+1122334455',
      driver_license_status: 'verified',
      status: 'active'
    }
  });

  console.log('👥 Usuarios creados:', { 
    host: hostUser.name, 
    renter: renterUser.name, 
    both: bothUser.name 
  });

  // Crear planes de seguro
  const basicInsurance = await prisma.insurancePlan.create({
    data: {
      insurance_plan_id: 'ins_basic_001',
      name: 'Basic',
      deductible: 500.00,
      daily_cost: 15.00,
      coverage_summary: 'Cobertura básica de responsabilidad civil',
      active: true
    }
  });

  const premiumInsurance = await prisma.insurancePlan.create({
    data: {
      insurance_plan_id: 'ins_premium_001',
      name: 'Premium',
      deductible: 250.00,
      daily_cost: 25.00,
      coverage_summary: 'Cobertura completa con deducible reducido',
      active: true
    }
  });

  console.log('🛡️ Planes de seguro creados');

  // Crear vehículos
  const vehicle1 = await prisma.vehicle.create({
    data: {
      vehicle_id: 'veh_001',
      owner_id: hostUser.user_id,
      make: 'Toyota',
      model: 'Camry',
      year: 2022,
      plate: 'ABC123',
      seats: 5,
      transmission: 'AT',
      fuel_type: 'hybrid',
      mileage: 15000,
      status: 'active',
      lat: 40.7128,
      lng: -74.0060,
    }
  });

  const vehicle2 = await prisma.vehicle.create({
    data: {
      vehicle_id: 'veh_002',
      owner_id: bothUser.user_id,
      make: 'Honda',
      model: 'CR-V',
      year: 2021,
      plate: 'XYZ789',
      seats: 7,
      transmission: 'AT',
      fuel_type: 'gas',
      mileage: 25000,
      status: 'active',
      lat: 40.7589,
      lng: -73.9851,
    }
  });

  console.log('🚗 Vehículos creados:', { 
    vehicle1: `${vehicle1.make} ${vehicle1.model}`, 
    vehicle2: `${vehicle2.make} ${vehicle2.model}` 
  });

  // Crear precios
  const pricing1 = await prisma.pricing.create({
    data: {
      pricing_id: 'price_001',
      vehicle_id: vehicle1.vehicle_id,
      daily_price: 75.00,
      min_days: 1,
      max_days: 30,
      currency: 'USD'
    }
  });

  const pricing2 = await prisma.pricing.create({
    data: {
      pricing_id: 'price_002',
      vehicle_id: vehicle2.vehicle_id,
      daily_price: 85.00,
      min_days: 1,
      max_days: 14,
      currency: 'USD'
    }
  });

  console.log('💰 Precios configurados');

  // Crear disponibilidad de vehículos
  const availability1 = await prisma.vehicleAvailability.create({
    data: {
      availability_id: 'avail_001',
      vehicle_id: vehicle1.vehicle_id,
      start_ts: new Date('2024-01-01T00:00:00Z'),
      end_ts: new Date('2024-12-31T23:59:59Z'),
      type: 'available',
      notes: 'Disponible todo el año'
    }
  });

  const availability2 = await prisma.vehicleAvailability.create({
    data: {
      availability_id: 'avail_002',
      vehicle_id: vehicle2.vehicle_id,
      start_ts: new Date('2024-01-01T00:00:00Z'),
      end_ts: new Date('2024-12-31T23:59:59Z'),
      type: 'available',
      notes: 'Disponible todo el año'
    }
  });

  console.log('📅 Disponibilidad configurada');

  // Crear reservas
  const booking1 = await prisma.booking.create({
    data: {
      booking_id: 'book_001',
      vehicle_id: vehicle1.vehicle_id,
      renter_id: renterUser.user_id,
      host_id: hostUser.user_id,
      insurance_plan_id: basicInsurance.insurance_plan_id,
      start_ts: new Date('2024-02-01T10:00:00Z'),
      end_ts: new Date('2024-02-03T18:00:00Z'),
      status: 'confirmed',
      daily_price_snapshot: 75.00,
      insurance_daily_cost_snapshot: 15.00,
      subtotal: 150.00,
      fees: 20.00,
      taxes: 15.00,
      total: 185.00,
      currency: 'USD',
      odo_start: 15000,
      odo_end: 15100,
      fuel_start: 80,
      fuel_end: 75
    }
  });

  const booking2 = await prisma.booking.create({
    data: {
      booking_id: 'book_002',
      vehicle_id: vehicle2.vehicle_id,
      renter_id: hostUser.user_id,
      host_id: bothUser.user_id,
      insurance_plan_id: premiumInsurance.insurance_plan_id,
      start_ts: new Date('2024-02-05T09:00:00Z'),
      end_ts: new Date('2024-02-07T17:00:00Z'),
      status: 'pending',
      daily_price_snapshot: 85.00,
      insurance_daily_cost_snapshot: 25.00,
      subtotal: 170.00,
      fees: 25.00,
      taxes: 17.00,
      total: 212.00,
      currency: 'USD'
    }
  });

  console.log('📋 Reservas creadas');

  // Crear pagos
  const payment1 = await prisma.payment.create({
    data: {
      payment_id: 'pay_001',
      booking_id: booking1.booking_id,
      payer_id: renterUser.user_id,
      amount: 185.00,
      currency: 'USD',
      status: 'captured',
      provider: 'stripe',
      provider_ref: 'stripe_pi_123456'
    }
  });

  console.log('�� Pagos creados');

  console.log('✅ Seed completado exitosamente!');
  console.log('\n📋 Datos de prueba:');
  console.log('👤 Usuarios:');
  console.log(`   Host: ${hostUser.email} / password123`);
  console.log(`   Renter: ${renterUser.email} / password123`);
  console.log(`   Both: ${bothUser.email} / password123`);
  console.log('\n🚗 Vehículos:');
  console.log(`   ${vehicle1.make} ${vehicle1.model} - $${pricing1.daily_price}/día`);
  console.log(`   ${vehicle2.make} ${vehicle2.model} - $${pricing2.daily_price}/día`);
  console.log('\n🔗 Endpoints disponibles:');
  console.log('   POST /api/auth/register - Registrar usuario');
  console.log('   POST /api/auth/login - Login de usuario');
  console.log('   GET /api/vehicles - Ver vehículos disponibles');
  console.log('   GET /api/bookings - Ver reservas');
}

main()
  .catch((e) => {
    console.error('❌ Error durante el seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });