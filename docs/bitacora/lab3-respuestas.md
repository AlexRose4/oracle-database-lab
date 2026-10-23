# Laboratorio 3 — Respuestas de comprobación

Entorno utilizado: MacBook Pro M1, terminal zsh y scripts Bash.
Oracle se ejecuta en Docker Desktop; SQLcl, SQL Developer y ORDS,
en macOS.

## Docker

### 1. ¿Qué diferencia hay entre una imagen y un contenedor? Usa como ejemplo lo que hiciste en los ejercicios G2 y G4.

Una imagen es la plantilla con los archivos y programas necesarios.
Un contenedor es una instancia creada desde ella. En G2 ejecuté un
contenedor desde hello-world; en G4 creé prueba desde alpine:3.20
y entré en su shell. La imagen permite crear distintos contenedores.

### 2. En el Ejercicio G5 el archivo nota.txt desapareció y en el G6 no. Explica por qué.

En G5 guardé el archivo en la capa escribible del contenedor.
Al eliminar ese contenedor, se perdió. En G6 lo guardé en el volumen
datos-prueba, montado en /datos. El volumen sobrevivió al primer
contenedor y otro contenedor pudo leer el archivo.

### 3. ¿Qué diferencia hay entre docker ps y docker ps -a, y qué significa STATUS = Exited (0)?

docker ps muestra los contenedores en ejecución; docker ps -a incluye
también los detenidos. Exited (0) indica que el proceso principal
terminó sin señalar un error. Lo comprobé con hello-world.

### 4. En -p 8181:8181, ¿qué número corresponde a tu equipo y cuál al contenedor? ¿Qué pasaría con -p 80:8080 en el ejercicio de nginx?

El primer número es el puerto del equipo y el segundo el del
contenedor. Con 8181:8181 se reenvían las conexiones del puerto 8181
del equipo al mismo puerto del contenedor. En nginx, 80:8080 dirigiría
mi puerto 80 al 8080 del contenedor, donde nginx no estaba escuchando.
El ejercicio funcionó con 8080:80.

En el entorno final, ORDS se ejecuta fuera del contenedor y sirve
Database Actions en el puerto 8080. Publicar 8181 en el contenedor
de Oracle no instala ni arranca ORDS.

### 5. ¿Por qué un contenedor de Oracle se queda en marcha y el de hello-world termina solo?

El contenedor permanece activo mientras lo hace su proceso principal.
hello-world imprime el mensaje y termina; Oracle mantiene procesos
de servicio para atender conexiones y trabajar con la base de datos.

### 6. ¿Qué es el digest de una imagen y por qué lo registramos si ya sabemos que usamos :latest?

El digest es una huella criptográfica del contenido de la imagen.
latest es una etiqueta que puede apuntar a otro contenido en el futuro.
Registrar el digest permite identificar exactamente lo descargado.

### 7. ¿Qué comando borraría realmente los datos de Oracle? ¿Por qué docker rm oralab-26ai no lo hace?

docker volume rm oralab-26ai-data eliminaría el volumen y sus datos
cuando ya no esté asociado a ningún contenedor. Es una operación
destructiva que no debo ejecutar sobre el entorno del curso.
docker rm oralab-26ai elimina el contenedor, pero conserva el volumen
con nombre donde se guardan los archivos de la base de datos.

## Git, organización y evidencia

### 8. ¿Por qué este laboratorio se hace dentro del repositorio oracle-database-lab, con Issue, branch y Pull Request, en vez de en una carpeta aparte?

Permite conservar el historial del curso, planificar el cambio,
relacionar scripts y evidencias con el Issue y revisar el trabajo
antes de incorporarlo a main. Utilicé el Issue #5 y la rama
chore/5-install-oracle-environment.

### 9. ¿Qué diferencia hay entre source 00-config.sh y bash 00-config.sh? ¿Por qué usamos source?

source ejecuta el archivo en la shell actual y deja disponibles sus
variables y funciones. bash lo ejecuta en un proceso hijo: sus cambios
de entorno no se trasladan a la shell que lo lanzó. Por eso cargo
00-config.sh con source en cada terminal nueva.

### 10. Explica cada parte del nombre 20260915T091230Z_02-docker.script.log.

20260915 es la fecha, 15 de septiembre de 2026. T separa fecha y hora;
091230 representa las 09:12:30 y Z indica UTC. 02 identifica el paso,
docker describe el contenido y .script.log identifica un registro
de terminal.

### 11. ¿Para qué sirve .gitattributes y qué error evita?

Establece reglas compartidas para los archivos del repositorio.
En esta práctica fija LF para .sh, .sql y .md. Evita que finales
de línea CRLF introducidos desde Windows provoquen errores como
$'\r': command not found al ejecutar scripts.

### 12. ¿Por qué en este Pull Request elegimos Create a merge commit en lugar de Squash and merge?

El merge commit conserva los commits individuales de cada parte,
incluidos los scripts y sus evidencias. Squash los agruparía en un
único commit y perderíamos esa separación en el historial de main.
La opción prevista para el cierre de esta práctica es merge commit.

## Seguridad

### 13. Describe las cuatro capas de la estrategia de contraseñas (Parte D) y qué pasaría si te saltas la primera.

Primero se excluye config/.env mediante .gitignore. Después se crea
.env.example con valores de ejemplo. La tercera capa es el archivo
privado .env con los valores reales y la comprobación de que Git lo
ignora. La cuarta consiste en cargar las variables para que los
comandos las utilicen sin escribir los valores en ellos.
Si se omite la primera capa, el archivo privado podría añadirse
accidentalmente a un commit.

### 14. ¿Por qué no escribimos la contraseña directamente en el comando docker run, aunque el script no se suba a Git?

El comando puede quedar en el historial de la shell, en una grabación
o en una captura, aunque el script no se publique. Utilizar la variable
evita escribir el valor en el comando guardado en el historial.
Esto no sustituye a proteger el acceso al equipo y al motor Docker.

### 15. Si descubres tu contraseña en un commit ya publicado, ¿basta con borrarla en un commit nuevo? ¿Qué debes hacer?

No. El valor permanece en el historial y puede haber sido copiado.
Hay que considerarlo comprometido, cambiarlo y avisar al docente
para coordinar la limpieza del historial. Después se revisa la causa
y se comprueba que no quedan secretos en archivos ni commits.

## Oracle y herramientas

### 16. ¿Por qué no usamos SPOOL ni @archivo.sql con sqlplus dentro del contenedor, y qué hicimos en su lugar?

SPOOL escribiría dentro del contenedor y @ buscaría allí el archivo,
no en mi repositorio del Mac. En su lugar envié el SQL mediante
redirección de entrada y guardé la salida con tee desde el anfitrión.
Con SQLcl instalado en el Mac sí utilicé SPOOL directamente sobre
una ruta del repositorio.

### 17. ¿Qué hace WHENEVER SQLERROR EXIT SQL.SQLCODE al inicio de V000 y V001, y qué pasaría sin esa línea?

Hace que SQL*Plus termine con un código de error cuando falla una
sentencia SQL o un bloque PL/SQL. El script Bash usa pipefail para
detectar ese fallo y no continuar con la siguiente migración.
Sin esa instrucción, SQL*Plus podría continuar sobre un estado parcial.
No revierte automáticamente las operaciones DDL ya realizadas.

### 18. ¿Qué es una migración y por qué V000 y V001 no se deben editar una vez aplicadas?

Es un script versionado que modifica la estructura de la base de datos.
V000 crea usuarios y tablespaces; V001 crea tablas e índices.
Editar una migración aplicada haría que el archivo dejara de representar
lo que se ejecutó. Las correcciones deben ir en una migración nueva
para mantener un historial reproducible.

### 19. ¿Por qué en SQL Developer se usa el servicio FREEPDB1 y no FREE ni un SID?

FREEPDB1 es la base de datos conectable donde creamos los usuarios
y las tablas del curso. FREE corresponde al servicio del contenedor
raíz. Se utiliza la conexión por nombre de servicio para seleccionar
la PDB correcta; un SID no identifica esa PDB como servicio.

### 20. ¿Qué aporta SQLcl frente a SQL*Plus, y por qué un DBA debe dominar ambas?

SQLcl ofrece una consola moderna, formatos de salida como ansiconsole,
gestión de conexiones y funciones adicionales de desarrollo.
SQL*Plus sigue siendo habitual en administración y automatización,
y ya venía instalado en el contenedor. He usado ambos para ejecutar
consultas y conservar evidencias.

## Entorno de trabajo

### 21. ¿Por qué el curso pasa de Git Bash a Ubuntu en WSL 2? Da al menos dos problemas concretos de Git Bash que desaparecen en Ubuntu.

En Windows, WSL 2 proporciona un entorno Linux real. Evita problemas
de Git Bash como la conversión automática de rutas en argumentos de
Docker y las dificultades con terminales interactivas, como not a TTY.
También permite disponer de herramientas Linux de administración.
En mi caso utilicé la alternativa macOS prevista por el PDF:
terminal nativa y Homebrew, sin instalar WSL.

### 22. ¿Por qué clonamos el repositorio en ~/oracle-database-lab y no trabajamos sobre la carpeta de Windows (/mnt/c/...)? ¿Y por qué recomendamos bash frente a zsh para los scripts del curso?

En WSL, trabajar en /home evita cruzar continuamente al sistema de
archivos de Windows mediante /mnt/c, lo que puede perjudicar el
rendimiento y complicar permisos. En mi Mac cloné el repositorio en
~/oracle-database-lab, dentro del sistema de archivos local.

Los scripts compartidos utilizan Bash porque es habitual en servidores
Linux y permite un comportamiento más uniforme. Puedo utilizar zsh
interactivamente en macOS y ejecutar los scripts con bash archivo.sh.
