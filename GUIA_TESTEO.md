# GUION PARA PREPARAR LA GUÍA DE TESTEO DE EZBAR

## Objetivo

Preparar una **guía clara** para que otro compañero pueda:

* Entender rápidamente tu aplicación
* Probar sus funcionalidades principales
* Detectar errores o comportamientos inesperados

---

## 1. Información básica de la aplicación

* **Nombre de la aplicación**: EZBar (Frontend)
* **Tipo de aplicación**: Gestión de Hostelería (TPV)
* **Objetivo principal de la app**: Ayudar a los camareros a gestionar pedidos y mesas desde el móvil para no usar papel.
* **Usuario al que va dirigida**: Camareros y encargados de bares o restaurantes.
* **Plataforma**: Android / iOS.
* **Versión a probar**: 1.0.0+1 (Alpha)

---

## 2. Descripción general de la aplicación

EZBar sirve para gestionar un bar o restaurante de forma digital. La idea principal es que los camareros puedan hacer login, ver un mapa de su zona (como la terraza o el comedor), tomar nota de lo que piden los clientes y mandarlo a cocina directamente. Así se evitan errores y se trabaja más rápido que con libreta y boli.

---

## 3. Flujos completos de uso (MUY IMPORTANTE)

Aquí tienes los pasos para probar las funciones más importantes de la app.

### Flujo 1: Inicio de Sesión
* **Objetivo**: Entrar en la app con un usuario válido.
* **Pantalla inicial**: Login (La pantalla verde del principio).
* **Pasos**:
  1. Escribe el usuario "admin".
  2. Escribe la contraseña "password123" (tiene que tener 8 caracteres mínimo).
  3. Dale al botón de "Login".
* **Resultado esperado**: Te tiene que salir un mensaje verde diciendo "¡Login exitoso!" y pasar a la pantalla principal donde se ven las zonas.

---

### Flujo 2: Creación de Zona y Mesas
* **Objetivo**: Crear un espacio nuevo en el restaurante y ponerle mesas.
* **Pantalla inicial**: Pantalla Principal.
* **Pasos**:
  1. Dale al botón "+" para añadir una zona.
  2. Ponle de nombre "Terraza Test" y confirma.
  3. Toca sobre el nombre de la nueva zona para que se despliegue.
  4. Donde pide nombre de mesa, escribe "Mesa 10".
  5. Dale al botón "+" de al lado para crearla.
* **Resultado esperado**: Tiene que salir la zona nueva en la lista, y dentro tienes que ver la "Mesa 10" con un círculo verde (que significa Libre).

---

### Flujo 3: Tomar Nota (Hacer un pedido)
* **Objetivo**: Apuntar lo que piden los clientes en una mesa.
* **Pantalla inicial**: Pantalla Principal (dentro de una zona).
* **Pasos**:
  1. Toca en una mesa que esté libre (verde).
  2. Verás la cuenta vacía. Dale al botón "Carta +" de abajo.
  3. Busca un producto, por ejemplo "Coca Cola", o navega por las categorías.
  4. Dale al botón "+" verde que hay a la derecha del producto.
  5. Vuelve atrás con la flecha de arriba a la izquierda.
* **Resultado esperado**: En la pantalla de la mesa tiene que salir la Coca Cola en la lista y el precio total debe haber subido.

---

### Flujo 4: Gestión de la Carta
* **Objetivo**: Añadir cosas nuevas al menú.
* **Pantalla inicial**: Abre el menú lateral y ve a "Editar Carta".
* **Pasos**:
  1. Baja hasta el final y dale a "Añadir Sección".
  2. Llámala "Especiales" y guarda.
  3. Abre esa sección nueva y escribe "Plato del Día".
  4. Dale al "+" verde para añadirlo.
* **Resultado esperado**: La categoría y el plato nuevo tienen que aparecer en la lista para poder pedirlos luego.

---

### Flujo 5: Eliminar una mesa
* **Objetivo**: Borrar una mesa que ya no existe o nos hemos equivocado.
* **Pantalla inicial**: Pantalla Principal.
* **Pasos**:
  1. Despliega una zona que tenga mesas.
  2. Dale a los 3 puntos que hay a la derecha de la mesa.
  3. Elige el icono de la papelera roja.
  4. Confirma que quieres borrarla.
* **Resultado esperado**: La mesa tiene que desaparecer de la lista al momento.

---

### Flujo 6: Cerrar Sesión
* **Objetivo**: Salir de la app de forma segura.
* **Pantalla inicial**: Cualquier pantalla.
* **Pasos**:
  1. Abre el menú lateral (el icono de las tres rayitas).
  2. Dale al botón "Cerrar sesión" que está abajo del todo.
* **Resultado esperado**: Te tiene que devolver a la pantalla de Login del principio.

---

## 4. Propuestas de pruebas de caja negra

Estas son pruebas para ver si la app falla o hace cosas raras sin mirar el código.

### Pruebas funcionales

**Prueba 1: Desplegar una Zona**
* **Pantalla**: Pantalla Principal.
* **Entrada**: Toca en el nombre de una zona cerrada (ej. "Barra").
* **Qué debe pasar**: La zona se tiene que abrir hacia abajo y mostrar las mesas que hay dentro. Si le das otra vez, se cierra.

**Prueba 2: Comprobación de suma (Dinero)**
* **Pantalla**: Cuenta de una mesa.
* **Entrada**: Añade dos productos (ej. uno de 10€ y otro de 2€).
* **Qué debe pasar**: El total de abajo debe marcar exactamente la suma (12€). Parece obvio, ¡pero en estas apps es lo más importante!

**Prueba 3: Cambiar mesa a Ocupado**
* **Pantalla**: Pantalla Principal.
* **Entrada**: Dale a los 3 puntos de una mesa -> Elige "Ocupado".
* **Qué debe pasar**: El círculo de la mesa tiene que ponerse ROJO.

**Prueba 4: Modo Oscuro**
* **Pantalla**: Ajustes Visuales (en el menú lateral).
* **Entrada**: Activa el interruptor de "Modo Oscuro".
* **Qué debe pasar**: Toda la app tiene que cambiar a fondo negro y letras blancas para que no moleste a la vista.

**Prueba 5: Cambiar Tamaño de Letra**
* **Pantalla**: Ajustes Visuales.
* **Entrada**: Cambia el selector de tamaño a "Grande".
* **Qué debe pasar**: Los textos de toda la aplicación deben volverse notablemente más grandes al instante.

**Prueba 6: Modo Daltónico**
* **Pantalla**: Ajustes Visuales.
* **Entrada**: Activa la opción "Modo Daltónico".
* **Qué debe pasar**: Los colores de la interfaz (como la barra superior o los círculos de las mesas) deben cambiar (ej. de verde a azul) para ser más distinguibles.

---

### Pruebas de error (para intentar "romper" la app)

**Prueba 6: Contraseña demasiado corta**
* **Entrada incorrecta**: Usuario "admin" y contraseña "123".
* **Acción**: Dale a Login.
* **Qué debe pasar**: Te tiene que salir un error diciendo que faltan caracteres (mínimo 8) y NO dejarte entrar.

**Prueba 7: Crear zona sin poner nombre**
* **Entrada incorrecta**: Deja el nombre de la zona vacío.
* **Acción**: Intenta añadirla.
* **Qué debe pasar**: No debería hacer nada o avisarte. Lo importante es que no cree una zona invisible o sin nombre.

**Prueba 8: Usuario con caracteres inválidos**
* **Entrada incorrecta**: Usuario con espacios o símbolos (ej. "admin@").
* **Acción**: Dale a Login.
* **Qué debe pasar**: Error indicando que el usuario no es válido (solo admite letras, números y guion bajo).

**Prueba 9: Borrar categoría con cosas dentro**
* **Acción**: Intenta borrar una sección de la carta que tenga platos dentro.
* **Qué debe pasar**: Debería preguntarte con un aviso de seguridad o impedir el borrado para no perder datos por error.

---

## 5. Comprobaciones generales para el tester

Aquí apunto cosas que quiero que miréis a ver si os pasan:

* ¿Se os cierra la app de repente si giráis el móvil? (Si lo probáis en un móvil real).
* ¿Hay algún botón en la carta que sea difícil de pulsar con el dedo?
* ¿Se cortan los nombres de los productos si son muy largos?
* ¿Os liáis al volver de la Carta a la Mesa o es intuitivo?

---

## 6. Observaciones finales

* **Persistencia**: Fijaos si al cerrar la app del todo y volver a abrirla siguen ahí las zonas que habéis creado.
* **Conexión**: Tened en cuenta que si el servidor falla, igual no cargan los datos, pero debería dejaros entrar si ya habíais entrado antes.

---

## 7. Documento para el tester

*(Este es el documento que tenéis que rellenar mientras probáis la app)*

# GUION DE TESTEO PARA PROBAR UNA APLICACIÓN MÓVIL

## Objetivo del testeo
Probar la aplicación EZBar como si fueras **un camarero real**, siguiendo mi guía y **anotando cualquier cosa rara que veas**.

---

## 1. Primer contacto con la aplicación

Marca y comenta:
* [ ] La aplicación se instala y abre bien.
* [ ] Entiendo rápido para qué sirve la app.
* [ ] La primera pantalla tiene sentido.
* [ ] Sé qué tengo que hacer sin que nadie me lo explique.

## Observaciones / problemas detectados
_________________________________________________________________________
_________________________________________________________________________

## 2. Navegación general

Comprueba:
* [ ] Los botones parecen botones de verdad.
* [ ] Se entiende lo que hacen los textos.
* [ ] Puedo volver atrás sin problemas.
* [ ] No me quedo “atrapado” en ninguna pantalla.
* [ ] Moverse por la app es lógico.

## Pantallas confusas o problemas
_________________________________________________________________________
_________________________________________________________________________

## 3. Ejecución de los flujos principales

### Flujo 1: Inicio de Sesión
* [ ] He podido hacerlo entero.
* [ ] El resultado final es el que esperaba.
* [ ] No han salido errores raros.

### Flujo 2: Creación de Zona y Mesas
* [ ] He podido hacerlo entero.
* [ ] El resultado final es el que esperaba.
* [ ] Se guardan los datos bien.

### Flujo 3: Tomar Nota
* [ ] He podido hacerlo entero.
* [ ] El resultado final es el que esperaba.
* [ ] Los precios se suman bien.

### Flujo 4: Gestión de Carta
* [ ] He podido hacerlo entero.
* [ ] El resultado final es el que esperaba.

### Flujo 5: Eliminar Elementos
* [ ] Se borra el elemento bien.
* [ ] Desaparece de la lista y no se queda ahí.

### Flujo 6: Cerrar Sesión
* [ ] Me devuelve al inicio para hacer login.

## Problemas encontrados en los flujos
_________________________________________________________________________
_________________________________________________________________________

## 4. Pruebas “normales” (uso esperado)

Comprueba que:
* [ ] Si meto los datos bien, la app funciona fina.
* [ ] Los botones responden rápido.
* [ ] No salen mensajes molestos sin sentido.
* [ ] Todo tiene coherencia.

## Errores o comportamientos raros
_________________________________________________________________________
_________________________________________________________________________

## 5. Pruebas de error (MUY IMPORTANTES)

Prueba a hacer cosas "mal" a propósito:
* [ ] Dejar campos vacíos (ej. crear zona sin nombre).
* [ ] Datos incorrectos (ej. login mal).
* [ ] Textos muy largos (ej. nombre de plato gigante).
* [ ] Repetir acciones muy rápido (ej. darle muchas veces al +).
* [ ] Volver atrás a mitad de hacer algo.

## ¿Qué esperabas que pasara? ¿Qué pasó realmente?
_________________________________________________________________________
_________________________________________________________________________

## 6. Mensajes y feedback

* [ ] Los mensajes de error se entienden.
* [ ] Sé por qué algo no funciona si falla.
* [ ] La app me avisa cuando algo sale bien (ej. sale un mensajito abajo).

## Mensajes mejorables o confusos
_________________________________________________________________________
_________________________________________________________________________

## 7. Aspectos visuales y usabilidad

* [ ] Los textos se leen bien (incluso en Modo Oscuro).
* [ ] Los botones están en sitios cómodos.
* [ ] Los colores no molestan.
* [ ] No hay cosas montadas encima de otras.

## Problemas visuales detectados
_________________________________________________________________________
_________________________________________________________________________

## 8. Estabilidad de la aplicación

* [ ] La app no se cierra sola (crashea).
* [ ] No se queda congelada.
* [ ] No salen pantallas en blanco.

## Cuándo y cómo falló (si ocurrió)
_________________________________________________________________________
_________________________________________________________________________

## 9. Valoración general

* ¿Te ha resultado fácil de usar? _________________
* ¿La usarías si no fuera un ejercicio? _________________
* ¿Qué es lo mejor de la app? _________________
* ¿Qué es lo primero que mejorarías? _________________

## Problemas detectados (resumen final)
1.
2.
3.
