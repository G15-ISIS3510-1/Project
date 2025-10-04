import asyncio
import random
import os
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from app.db.models import VehicleRating, Vehicle, Booking, User
from sqlalchemy import select
import uuid

async def seed_vehicle_ratings():
    """Crear MUCHOS datos de prueba para calificaciones de vehículos"""
    # Crear engine asíncrono usando DATABASE_URL del entorno o por defecto
    database_url = os.getenv("DATABASE_URL", "postgresql+asyncpg://marcosespana@127.0.0.1:5432/qovo_db")
    async_engine = create_async_engine(database_url)
    
    async with AsyncSession(async_engine) as db:
        try:
            # Obtener TODOS los vehículos
            result = await db.execute(select(Vehicle))
            vehicles = result.scalars().all()
            
            if not vehicles:
                print("No hay vehículos en la base de datos. Ejecuta primero seed_vehicles.py")
                return
            
            # Obtener TODOS los usuarios
            result = await db.execute(select(User))
            users = result.scalars().all()
            
            if not users:
                print("No hay usuarios en la base de datos. Ejecuta primero seed_users.py")
                return
            
            # Obtener TODAS las reservas completadas
            result = await db.execute(
                select(Booking).where(Booking.status == "completed")
            )
            bookings = result.scalars().all()
            
            if not bookings:
                print("No hay reservas completadas en la base de datos. Ejecuta primero seed_bookings.py")
                return
            
            print(f"📊 Preparando datos:")
            print(f"   - Vehículos disponibles: {len(vehicles)}")
            print(f"   - Usuarios disponibles: {len(users)}")
            print(f"   - Reservas completadas: {len(bookings)}")
            
            # Comentarios variados y realistas
            comments_excellent = [
                "¡Increíble experiencia! El vehículo estaba impecable y el servicio fue excepcional.",
                "Superó todas mis expectativas. Vehículo en perfectas condiciones.",
                "Excelente vehículo, muy cómodo y en perfecto estado. 100% recomendado.",
                "No puedo estar más satisfecho. Todo fue perfecto de principio a fin.",
                "El mejor alquiler que he tenido. Vehículo limpio, moderno y confiable.",
                "Servicio de primera calidad. El vehículo estaba como nuevo.",
                "Experiencia fantástica. Definitivamente volveré a alquilar aquí.",
                "El vehículo superó mis expectativas. Muy bien mantenido.",
                "Perfecto en todos los aspectos. Highly recommended!",
                "Excelente relación calidad-precio. El vehículo estaba impecable.",
                "Todo fue increíble. El propietario fue muy profesional.",
                "Vehículo en excelente estado, limpio y con todas las comodidades.",
                "Una experiencia de 10. Sin duda volveré a alquilar.",
                "El mejor servicio de alquiler que he probado. Todo perfecto.",
                "Vehículo de lujo en perfectas condiciones. Vale cada peso.",
                "Servicio impecable y vehículo de primera. Muy recomendado.",
                "Experiencia maravillosa. El vehículo estaba mejor de lo esperado.",
                "Todo salió perfecto. Vehículo limpio, moderno y confiable.",
                "Calidad excepcional. El vehículo estaba en estado impecable.",
                "Definitivamente el mejor alquiler que he hecho. 5 estrellas merecidas."
            ]
            
            comments_very_good = [
                "Muy buen servicio, el vehículo estaba limpio y funcionando perfecto.",
                "Muy satisfecho con la experiencia. El vehículo cumplió perfectamente.",
                "Buen vehículo, cómodo y confiable. Lo recomiendo sin dudas.",
                "El propietario fue muy amable y el vehículo estaba en excelente estado.",
                "Experiencia muy positiva. El vehículo funcionó de maravilla.",
                "Todo salió muy bien. Vehículo limpio y en buen estado.",
                "Muy contento con el alquiler. El vehículo era exactamente como se describía.",
                "Buen servicio al cliente y vehículo muy confiable.",
                "El vehículo estaba muy bien cuidado. Experiencia muy buena.",
                "Muy recomendable. El vehículo estaba limpio y funcionaba perfecto.",
                "Excelente opción para alquilar. Todo fue muy profesional.",
                "Muy buena experiencia. El vehículo estaba en muy buen estado.",
                "Servicio eficiente y vehículo de calidad. Muy satisfecho.",
                "El vehículo cumplió con todas mis expectativas. Muy bueno.",
                "Experiencia muy positiva. Volvería a alquilar sin dudarlo.",
                "Muy buen precio y excelente calidad del vehículo.",
                "Todo fue muy bien organizado. El vehículo era genial.",
                "Muy satisfecho con el servicio y el estado del vehículo.",
                "Buen vehículo, cómodo para viajes largos. Muy recomendado.",
                "El vehículo estaba muy bien mantenido. Experiencia positiva."
            ]
            
            comments_good = [
                "Buen servicio en general. El vehículo cumplió su función.",
                "El vehículo estaba bien, sin problemas durante el alquiler.",
                "Experiencia positiva. El vehículo era adecuado para mis necesidades.",
                "Buen precio por la calidad ofrecida. Vehículo funcional.",
                "El vehículo cumplió con mis expectativas básicas.",
                "Servicio correcto. El vehículo estaba en condiciones aceptables.",
                "Todo bien en general. El vehículo funcionó sin problemas.",
                "Buen alquiler. El vehículo era cómodo y confiable.",
                "Experiencia satisfactoria. El vehículo estaba bien mantenido.",
                "El servicio fue bueno y el vehículo estaba limpio.",
                "Vehículo adecuado para el precio. Sin quejas importantes.",
                "Todo correcto. El vehículo cumplió con lo prometido.",
                "Buen servicio, aunque el vehículo tenía algunos años.",
                "El vehículo estaba bien. Nada espectacular pero cumplió.",
                "Experiencia decente. El vehículo era funcional.",
                "Buen precio. El vehículo estaba en condiciones aceptables.",
                "Servicio adecuado. El vehículo funcionó bien durante el alquiler.",
                "Todo estuvo bien. El vehículo era lo que esperaba.",
                "Buen alquiler en general. El vehículo cumplió su propósito.",
                "El vehículo estaba bien cuidado. Experiencia satisfactoria."
            ]
            
            comments_average = [
                "El vehículo tenía algunos detalles menores pero funcionaba.",
                "Experiencia aceptable. El vehículo podría estar mejor mantenido.",
                "El servicio fue correcto, aunque el vehículo no era el más moderno.",
                "Funcionó bien, pero el vehículo mostraba signos de uso.",
                "El vehículo cumplió, aunque esperaba algo en mejor estado.",
                "Servicio normal. El vehículo tenía algunos rasguños menores.",
                "Aceptable para el precio. El vehículo funcionó sin grandes problemas.",
                "El vehículo era antiguo pero todavía servía.",
                "Experiencia regular. El vehículo podría mejorar en limpieza.",
                "El servicio fue básico. El vehículo cumplió lo mínimo.",
                "Ni bueno ni malo. El vehículo funcionó pero tenía detalles.",
                "El vehículo estaba algo gastado pero sirvió para el viaje.",
                "Experiencia promedio. El vehículo necesita mantenimiento.",
                "Cumplió su función, aunque el vehículo no era lo mejor.",
                "El precio estaba bien para lo que ofrecía el vehículo.",
                "Servicio básico. El vehículo tenía algunos detalles estéticos.",
                "El vehículo funcionó, pero le faltaba mantenimiento.",
                "Experiencia aceptable. El vehículo era usado pero funcional.",
                "Todo normal. El vehículo cumplió sin destacar.",
                "El servicio fue estándar. El vehículo tenía su edad."
            ]
            
            comments_below_average = [
                "El vehículo tenía varios problemas menores que afectaron la experiencia.",
                "No quedé muy satisfecho. El vehículo no estaba en el mejor estado.",
                "El servicio fue deficiente y el vehículo tenía problemas mecánicos.",
                "Experiencia decepcionante. El vehículo no cumplió las expectativas.",
                "El vehículo tenía muchos detalles negativos. No lo recomendaría.",
                "Mal estado del vehículo. Tuve que reportar varios problemas.",
                "No volvería a alquilar. El vehículo estaba descuidado.",
                "El servicio fue pobre y el vehículo tenía fallas.",
                "Experiencia negativa. El vehículo no estaba bien mantenido.",
                "El vehículo tenía problemas desde el inicio del alquiler.",
                "No estoy satisfecho con la calidad del vehículo.",
                "El servicio dejó mucho que desear. Vehículo en mal estado.",
                "Experiencia frustrante. El vehículo tenía múltiples fallas.",
                "No recomiendo este alquiler. El vehículo estaba descuidado.",
                "El vehículo no funcionaba correctamente. Muy decepcionante.",
                "Mal servicio y peor vehículo. No cumplió lo prometido.",
                "El vehículo estaba en pésimas condiciones para alquilar.",
                "Experiencia muy mala. El vehículo tenía serios problemas.",
                "No vale la pena. El vehículo estaba en mal estado.",
                "Servicio deficiente y vehículo con múltiples problemas."
            ]
            
            comments_poor = [
                "Pésima experiencia. El vehículo estaba en muy mal estado.",
                "No puedo recomendar este servicio. El vehículo era un desastre.",
                "El peor alquiler que he tenido. Vehículo completamente descuidado.",
                "Terrible estado del vehículo. Tuve muchos problemas.",
                "No alquilen aquí. El vehículo tenía fallas graves.",
                "Experiencia horrible. El vehículo no debería estar disponible.",
                "El vehículo se descompuso durante el alquiler. Pésimo servicio.",
                "Muy mal estado. El vehículo era peligroso de conducir.",
                "No vale absolutamente nada. Vehículo en condiciones deplorables.",
                "El peor servicio posible. El vehículo estaba destruido.",
                "Experiencia desastrosa. El vehículo no funcionaba bien.",
                "Totalmente insatisfecho. El vehículo era un peligro.",
                "No recomiendo bajo ninguna circunstancia. Vehículo terrible.",
                "El vehículo estaba en condiciones inaceptables.",
                "Pésimo servicio y vehículo en condiciones lamentables."
            ]
            
            # Crear MUCHAS calificaciones
            ratings_data = []
            batch_size = 1000  # Insertar en lotes de 1000
            total_ratings = 0
            
            # Para cada reserva completada, crear múltiples calificaciones
            for booking in bookings:
                # Crear entre 3-8 calificaciones por reserva (simulando múltiples usuarios)
                num_ratings = random.randint(3, 8)
                
                for _ in range(num_ratings):
                    # Seleccionar un usuario aleatorio (diferente al renter)
                    available_users = [u for u in users if u.user_id != booking.renter_id]
                    if not available_users:
                        continue
                    
                    rater = random.choice(available_users)
                    
                    # Generar calificación con distribución realista
                    # La mayoría son buenas (4-5), algunas regulares (3), pocas malas (1-2)
                    rating_value = random.choices(
                        [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0],
                        weights=[2, 3, 5, 7, 15, 18, 20, 15, 15]  # Distribución realista
                    )[0]
                    
                    # Seleccionar comentario basado en la calificación
                    if rating_value >= 4.5:
                        comment = random.choice(comments_excellent)
                    elif rating_value >= 4.0:
                        comment = random.choice(comments_very_good)
                    elif rating_value >= 3.5:
                        comment = random.choice(comments_good)
                    elif rating_value >= 2.5:
                        comment = random.choice(comments_average)
                    elif rating_value >= 2.0:
                        comment = random.choice(comments_below_average)
                    else:
                        comment = random.choice(comments_poor)
                    
                    # Fecha de calificación: entre 1-14 días después de la reserva
                    rating_date = booking.created_at + timedelta(days=random.randint(1, 14))
                    
                    rating = VehicleRating(
                        rating_id=str(uuid.uuid4()),
                        vehicle_id=booking.vehicle_id,
                        booking_id=booking.booking_id,
                        renter_id=rater.user_id,
                        rating=rating_value,
                        comment=comment,
                        created_at=rating_date
                    )
                    
                    ratings_data.append(rating)
                    total_ratings += 1
                    
                    # Insertar en lotes
                    if len(ratings_data) >= batch_size:
                        db.add_all(ratings_data)
                        await db.commit()
                        print(f" Insertados {total_ratings} calificaciones...")
                        ratings_data = []
            
            # Insertar el último lote
            if ratings_data:
                db.add_all(ratings_data)
                await db.commit()
            
            print(f"\n ¡Proceso completado!")
            print(f" Se crearon {total_ratings} calificaciones de vehículos")
            
            # Mostrar estadísticas detalladas
            result = await db.execute(select(VehicleRating))
            all_ratings = result.scalars().all()
            
            if all_ratings:
                avg_rating = sum(r.rating for r in all_ratings) / len(all_ratings)
                
                # Contar por calificación
                rating_distribution = {}
                for r in all_ratings:
                    rating_distribution[r.rating] = rating_distribution.get(r.rating, 0) + 1
                
                print(f"\n Estadísticas Generales:")
                print(f"   - Total de calificaciones: {len(all_ratings):,}")
                print(f"   - Calificación promedio: {avg_rating:.2f} ⭐")
                print(f"   - Calificación mínima: {min(r.rating for r in all_ratings)}")
                print(f"   - Calificación máxima: {max(r.rating for r in all_ratings)}")
                
                print(f"\n Distribución de Calificaciones:")
                for rating in sorted(rating_distribution.keys(), reverse=True):
                    count = rating_distribution[rating]
                    percentage = (count / len(all_ratings)) * 100
                    bar = "█" * int(percentage / 2)
                    print(f"   {rating} ⭐: {count:,} ({percentage:.1f}%) {bar}")
                
                # Calificaciones por vehículo
                vehicle_ratings = {}
                for r in all_ratings:
                    if r.vehicle_id not in vehicle_ratings:
                        vehicle_ratings[r.vehicle_id] = []
                    vehicle_ratings[r.vehicle_id].append(r.rating)
                
                print(f"\nTop 5 Vehículos Mejor Calificados:")
                vehicle_averages = {
                    v_id: sum(ratings) / len(ratings) 
                    for v_id, ratings in vehicle_ratings.items()
                }
                top_vehicles = sorted(vehicle_averages.items(), key=lambda x: x[1], reverse=True)[:5]
                
                for idx, (v_id, avg) in enumerate(top_vehicles, 1):
                    num_ratings = len(vehicle_ratings[v_id])
                    print(f"   {idx}. Vehículo {v_id[:8]}... - {avg:.2f} ⭐ ({num_ratings} calificaciones)")
            
        except Exception as e:
            print(f" Error creando calificaciones: {e}")
            await db.rollback()
            raise
        finally:
            await async_engine.dispose()

if __name__ == "__main__":
    print("🚀 Iniciando generación masiva de calificaciones...")
    print("⏳ Esto puede tomar varios minutos...\n")
    asyncio.run(seed_vehicle_ratings())