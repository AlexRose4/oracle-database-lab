# Laboratorio 1 - Git Fundamentals

## Preguntas de comprobación

### 1. ¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un archivo pasando por las tres.

El Working Directory es la carpeta de trabajo donde se encuentran los archivos que estoy creando o modificando. La Staging Area es una zona intermedia en la que preparo los cambios que quiero incluir en el siguiente commit. El Local Repository es donde Git almacena el historial de commits dentro de la carpeta `.git`.

Durante la práctica pude comprobarlo con `README.md`. Primero modifiqué el archivo en el Working Directory. Después ejecuté `git add README.md`, pasando ese cambio a la Staging Area. Finalmente, al ejecutar `git commit`, el cambio quedó registrado en el historial del repositorio local.

### 2. Si modificas un archivo pero no haces `git add`, ¿aparece ese cambio en tu próximo commit? Explica por qué.

No. Un cambio realizado en el Working Directory no se incluye automáticamente en el siguiente commit. Para incluirlo primero hay que utilizar `git add` y pasarlo a la Staging Area. El comando `git commit` registra únicamente los cambios que se encuentran preparados en esa zona.

Durante la práctica lo comprobé con `docs/customer-schema.md`. Intenté realizar el commit sin haber añadido antes el archivo y Git indicó que había archivos sin seguimiento, pero no creó el commit. Después ejecuté `git add docs/customer-schema.md` y pude realizar el commit correctamente.

### 3. ¿Por qué git status no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para solucionarlo?

Git no versiona carpetas directamente, sino archivos. Por este motivo, una carpeta completamente vacía no aparece en `git status` y tampoco puede quedar registrada en un commit.

Para solucionarlo añadimos archivos `.gitkeep` dentro de las carpetas que debían conservarse aunque estuvieran vacías. `.gitkeep` no es una función especial de Git, sino una convención que permite que exista un archivo dentro de la carpeta y, de esta forma, Git pueda incluir esa estructura en el repositorio.

### 4. Explica con tus palabras qué es HEAD.

HEAD es el puntero que indica en qué posición del historial de Git me encuentro actualmente, normalmente asociado al último commit de la branch en la que estoy trabajando.

Durante la práctica pude comprobarlo al cambiar entre `main` y `feature/customer-search`. Al cambiar de branch con `git switch`, HEAD pasó a apuntar a la nueva branch y Git actualizó el contenido del Working Directory para mostrar los archivos correspondientes a esa versión del proyecto. Por ejemplo, `customer-search.md` aparecía al estar en `feature/customer-search` y desaparecía al volver a `main`, porque ese archivo solo existía en la branch de la funcionalidad.

### 5. ¿Qué diferencia hay entre crear una branch con `git switch -c` y crear una carpeta nueva con `mkdir`? ¿Cómo lo comprobamos en la Parte G?

`git switch -c` crea una nueva branch, es decir, una nueva línea de evolución dentro del historial de Git. En cambio, `mkdir` crea físicamente una carpeta nueva en el sistema de archivos. Por tanto, una branch no es una carpeta.

Durante la práctica creé la branch `feature/customer-search` con `git switch -c feature/customer-search`. Después utilicé `ls -la` y comprobé que no había aparecido ninguna carpeta llamada `feature` ni `customer-search`. También comprobé que, al cambiar entre `main` y `feature/customer-search`, Git modificaba el contenido del Working Directory según la branch seleccionada.

### 6. Durante el conflicto de la Parte H, ¿qué representaba el contenido entre `<<<<<<< HEAD` y `=======`? ¿Y entre `=======` y `>>>>>>>`?

Durante el conflicto, el contenido situado entre `<<<<<<< HEAD` y `=======` representaba la versión que ya existía en la branch en la que me encontraba, que en nuestro caso era `main`. El contenido situado entre `=======` y `>>>>>>> fix/readme-subtitle` representaba la versión procedente de la branch que estaba intentando fusionar.

En nuestro conflicto, una versión del título del README era `Oracle Database Lab (Training Edition)` y la otra era `Oracle Database Lab – Academic Version`. Git no podía decidir automáticamente cuál debía conservar, por lo que marcó el conflicto. Lo resolví manualmente combinando ambas versiones en `Oracle Database Lab (Training Edition — Academic Version)`, eliminando los marcadores, ejecutando `git add README.md` y realizando el commit de resolución del merge.

### 7. ¿Por qué NO se debe hacer `git commit --amend` sobre un commit que ya se subió con `git push`?

No se debe utilizar `git commit --amend` sobre un commit que ya se ha subido porque `--amend` reescribe el último commit y genera un nuevo hash. Si el commit original ya existe en GitHub o ha sido descargado por otros compañeros, el historial local y el remoto pueden quedar diferentes y provocar problemas de sincronización.

Durante la práctica utilicé `--amend` para corregir el mensaje de un commit, pero lo hicimos antes de subir ese historial a GitHub. Una vez realizado un `push`, es más seguro considerar esos commits como compartidos y realizar un nuevo commit para corregirlos en lugar de reescribirlos.

### 8. Si borras por accidente la carpeta `.git` de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también el código fuente que está en el disco?

La carpeta `.git` contiene la información que convierte una carpeta normal en un repositorio Git, incluyendo el historial de commits, las branches, referencias y otra información necesaria para el control de versiones local.

Si elimino `.git`, los archivos normales del proyecto que están en el Working Directory no desaparecen. Por ejemplo, seguirían existiendo `README.md`, `docs` o `database`, pero esa carpeta dejaría de funcionar como el repositorio Git que habíamos creado y perdería su historial local y sus referencias. Si el repositorio ya estuviera correctamente almacenado en GitHub, existiría además una copia remota desde la que podría recuperarse el repositorio.

### 9. Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube".

Git es el sistema de control de versiones que utilizo en mi equipo para registrar cambios, crear commits, trabajar con branches, consultar el historial o realizar merges. Puede funcionar localmente sin necesidad de GitHub.

GitHub es una plataforma que aloja repositorios Git en un servidor y permite compartirlos, sincronizarlos y colaborar con otras personas. En esta práctica primero trabajé únicamente con Git de forma local y posteriormente vinculé el repositorio con GitHub mediante `origin`. Después utilicé `git push` para enviar commits a GitHub y `git pull` para traer a mi equipo un cambio que había realizado desde la interfaz web.

### 10. ¿Por qué no se debe subir un archivo `.env` con contraseñas reales a un repositorio, aunque el repositorio sea privado?

Un archivo `.env` puede contener información sensible como contraseñas, tokens, claves de acceso o credenciales de bases de datos. No se debe incluir esta información en el repositorio porque una persona que consiga acceso al mismo podría obtener esas credenciales.

Además, una vez que un secreto se incluye en un commit puede permanecer en el historial aunque posteriormente se elimine del archivo actual. Por este motivo, este tipo de archivos debe excluirse mediante `.gitignore` y las credenciales deben gestionarse fuera del código versionado.

### 11. Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fast-forward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero?

Probablemente el repositorio remoto contiene uno o varios commits que todavía no existen en el repositorio local. Esto puede ocurrir, por ejemplo, si otra persona ha subido cambios o si se ha realizado un commit directamente desde la interfaz web de GitHub.

Lo primero que ejecutaría sería `git pull` para traer e integrar los cambios remotos en mi branch local. Si apareciera algún conflicto tendría que resolverlo antes de volver a ejecutar `git push`.

En la práctica hicimos una situación relacionada: modificamos `README.md` directamente desde GitHub en `fix/readme-subtitle`. Después ejecuté `git pull` desde esa branch y Git descargó el nuevo commit mediante un `fast-forward`, tras lo cual el cambio `Updated from GitHub web interface.` apareció también en mi copia local.

### 12. ¿Qué tipo de Conventional Commit (`feat`, `fix`, `docs`, `test`…) usarías para: añadir un índice de rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README?

Para añadir un índice destinado a mejorar el rendimiento de una tabla utilizaría `perf`, ya que se trata de una mejora de rendimiento. Por ejemplo: `perf: add index to improve query performance`.

Para corregir una restricción mal definida utilizaría `fix`, porque estoy corrigiendo un comportamiento o definición incorrecta. Por ejemplo: `fix: correct customer table constraint`.

Para actualizar el README utilizaría `docs`, ya que el cambio afecta únicamente a documentación. Por ejemplo: `docs: update README`.