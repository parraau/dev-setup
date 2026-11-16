---
name: "estandar-code-augu"
description: "Estándar permanente de Augu para todo código con UI o copy (artifacts, dashboards, apps, páginas): Modern Web Guidance + craft floor de impeccable + no-ai-slop + capa de seguridad (Semgrep, dependencias, secretos, CSP, OWASP), verificado con los detectores."
---

# Estándar de código y UI de Augu

Fuentes permanentes (consultarlas si hay dudas o versión nueva):
- https://github.com/pbakaus/impeccable · https://impeccable.style (diseño frontend)
- https://github.com/petergyang/no-ai-slop (texto y copy)
- https://semgrep.dev · https://cheatsheetseries.owasp.org · https://owasp.org/www-project-application-security-verification-standard (seguridad)
- https://github.com/GoogleChrome/modern-web-guidance · https://developer.chrome.com/docs/modern-web-guidance (plataforma web, APIs nativas, compatibilidad Baseline)

Aplica a todo proyecto nuevo y a toda mejora de un proyecto existente. Si el proyecto tiene un brief o identidad visual propia, el brief manda; el estándar cubre la mecánica.

## 0. Plataforma (Modern Web Guidance)

Objetivo de compatibilidad por defecto: Baseline "Widely available". Si el proyecto define otro objetivo (por ejemplo, navegadores viejos en clientes corporativos), manda el del proyecto.

Antes de implementar cualquier componente o patrón de UI (diálogos, popovers, menús, drawers, tooltips, formularios, animaciones, carga de imágenes, rendimiento):
1. Buscar la guía: `npx -y modern-web-guidance@latest search "<qué hay que construir>"`.
2. Traer las que apliquen: `npx -y modern-web-guidance@latest retrieve <id1>,<id2>` y seguirlas.
3. Preferir la API nativa del navegador antes que una librería. Cada dependencia que se agregue tiene que justificarse por algo que la plataforma no resuelve (paso 2 del algoritmo: eliminar).
4. No usar funciones experimentales (Origin Trials o volátiles) salvo pedido explícito.

En proyectos existentes, auditar código heredado:
`npx -y modern-web-guidance@latest legacy-scan <carpeta> --json`
El escáner cubre solo parte de las guías; para el resto, buscar por tema con `search`.

## 1. Diseño (craft floor de impeccable)

Verificar sobre el resultado construido, no como intención:
- Contraste: texto ≥4,5:1, texto grande ≥3:1, en claro Y en oscuro. Nada de gris sobre fondo de color: teñir desde el tono del fondo.
- Texto funcional ≥11 px (etiquetas, celdas, chips, botones); cuerpo ≥12 px; medida de cuerpo 65–75ch.
- Profundidad: sombra con offset y blur suave. No combinar borde de 1 px con sombra difusa ancha: elegir uno.
- Estados: hover, disabled, loading, error, vacío, foco de teclado.
- Superficies del navegador tematizadas: ::selection, caret, scrollbar, focus ring, text-underline-offset, números tabulares en datos.
- Responsive: sin scroll horizontal a 390 px (romper URLs largas, min-width:0 en hijos de grid).

Rechazar por defecto:
- Kicker/eyebrow arriba del título (prohibido siempre).
- Números de sección 01/02/03 si la secuencia no informa nada.
- Borde lateral de color >1 px en tarjetas, avisos o ítems (side-tab).
- Texto con gradiente. Glass/blur decorativo. Sombras duras offset fuera de un mundo neobrutalista.
- Grillas de tarjetas iguales ícono+título+texto; tarjetas anidadas.
- Template de métrica-héroe (número grande + etiqueta + stats).
- Emoji o glifos Unicode como sistema de íconos: usar SVG de trazo consistente.
- Mayúsculas en pasajes largos (solo etiquetas cortas).
- Monoespaciada como disfraz: solo para código, datos o medidas.
- Claro/oscuro elegido por categoría y no por escena de uso.

## 1.5 Seguridad (permanente)

Reglas de código, siempre:
- Nunca `innerHTML`, `outerHTML`, `insertAdjacentHTML` ni `document.write` con datos de usuario o de API: usar `textContent` o creación de nodos. Si hace falta HTML, sanitizar con DOMPurify.
- Nada de `eval`, `new Function`, `setTimeout(string)` ni handlers inline (`onclick="..."`): rompen la CSP.
- Cero secretos en el frontend ni en el repo (API keys, tokens, certificados ARCA, contraseñas). Van en variables de entorno o en un gestor de secretos del servidor; `.env` siempre en `.gitignore`.
- Toda validación de seguridad se repite en el servidor; la del cliente es solo UX.
- Links externos con `rel="noopener noreferrer"`. Formularios con autocomplete correcto y sin datos sensibles en la URL.
- Dependencias: cada librería nueva se justifica (ver paso 0) y se fija versión con lockfile commiteado.

Encabezados HTTP en todo lo que se publique en servidor propio (nginx, Node, Django):
- `Content-Security-Policy`: partir de `default-src 'self'; script-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'` y abrir solo lo necesario, con dominios concretos. Sin `'unsafe-inline'` ni `'unsafe-eval'` en scripts; si hay scripts inline, usar nonce o hash.
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy` restrictiva.
- Cookies de sesión: `Secure; HttpOnly; SameSite=Lax` (o `Strict`).
- En artifacts publicados en claude.ai los encabezados los pone la plataforma: aplicar solo las reglas de código.

OWASP completo, de ser necesario. Se activa si el proyecto tiene alguno de estos: login o sesiones, backend o API propia, datos personales de clientes, pagos o facturación (ARCA), control de dispositivos remotos (Vigía, CCTV), o panel administrativo expuesto a internet. En ese caso revisar contra OWASP Top 10 y ASVS nivel 1 (nivel 2 si hay pagos, datos personales o control físico): autenticación, control de acceso por objeto (IDOR), inyección SQL/comandos, CSRF, rate limiting en login, logs sin datos sensibles, manejo de errores sin stack traces al usuario. Usar los Cheat Sheets de OWASP como referencia por tema.

## 2. Copy (no-ai-slop)

- Edición mínima efectiva; conservar la voz de Augu (argentino, directo).
- Cortar: delve, leverage, robust, cutting-edge, transformative, seamless, 'es importante destacar', 'en el mundo de hoy', 'la clave es'.
- Cortar patrones: contrastes binarios 'No es X, es Y', aperturas de carraspeo, revelaciones con dos puntos, remates aforísticos, cierres que resumen, cadencia robótica.
- Rayas (—): ninguna en copy corto; pocas en textos largos. Incisos numéricos van entre paréntesis.
- Concreto > abstracto: nombres, números, fechas, mecanismos.
- Español con tildes completas: revisar strings de UI y de JS, no solo el HTML.

## 3. Verificación obligatoria antes de entregar

0. Correr `npx -y modern-web-guidance@latest legacy-scan <carpeta o archivo>` y corregir los hallazgos (o justificar en la entrega por qué se dejan).
1. Correr el detector de diseño sobre cada archivo o URL:
   `npx impeccable detect <archivo.html>` (o el binario del repo clonado: `plugin/skills/impeccable/scripts/impeccable detect`). Con `--json` para ver snippets.
2. Corregir todos los hallazgos primarios. Si alguno se deja a propósito (falso positivo o decisión de brief), decirlo explícitamente en la entrega.
3. Render con Playwright a 1280 px claro y 390 px oscuro; revisar capturas y confirmar sin scroll horizontal.
4. `node --check` sobre el JS extraído si se tocaron strings dentro de scripts.
5. Seguridad (sobre la carpeta del proyecto):
   - Código: `semgrep scan --config p/javascript --config p/typescript --config p/owasp-top-ten --config p/secrets --metrics=off <carpeta>` (sumar `p/python` o `p/django` si hay backend Python). Instalar con `pip install semgrep` si falta.
   - Secretos en el historial: `gitleaks detect --source <carpeta>` si el binario está disponible; si no, alcanza con `p/secrets` de Semgrep y decirlo en la entrega.
   - Dependencias: `npm audit --audit-level=high` (o `pnpm audit` / `pip-audit`). Sin vulnerabilidades altas o críticas abiertas; si una no tiene parche, documentarla con su mitigación.
   - Encabezados: si el sitio está publicado en servidor propio, verificar CSP y demás con `curl -sI <url>` y Mozilla Observatory; objetivo nota A o superior.
   - Si aplica OWASP completo (ver 1.5), entregar el checklist ASVS marcado.
6. Una ronda de corrección + una de confirmación; no iterar en loop.

## 4. Entrega

Incluir sección de seguridad: hallazgos de Semgrep, dependencias y secretos (corregidos, aceptados con motivo, o falsos positivos), estado de encabezados y, si aplicó, resultado del checklist OWASP. Un hallazgo crítico sin resolver bloquea la entrega a producción: se avisa, no se publica.

Informar por proyecto: qué patrones heredados se reemplazaron por APIs nativas (y qué dependencias se eliminaron), qué se corrigió, qué quedó intencional y por qué, y bugs funcionales detectados fuera del alcance del estándar.