# 🚀 GUÍA RÁPIDA DE ACCESO - ESP32 v2.0.0

## 📂 Ubicación del Proyecto

```
/home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
```

---

## ⚡ ACCESO RÁPIDO

### Método 1: Script Interactivo (Más Fácil)
```bash
cd /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
./open_docs.sh
```

### Método 2: Explorador de Archivos
```bash
# Linux
xdg-open /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/

# Nautilus
nautilus /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
```

### Método 3: VS Code
```bash
code /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
```

### Método 4: GitHub Online
```
https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/tree/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk
```

---

## 📄 ARCHIVOS PRINCIPALES

| Archivo | Comando para Ver |
|---------|------------------|
| **README** | `cat README.md \| less` |
| **BOM** | `cat BOM.md \| less` |
| **SHOPPING LIST** | `cat SHOPPING_LIST.md \| less` |
| **WIRING DIAGRAM** | `cat WIRING_DIAGRAM.md \| less` |
| **CHANGELOG** | `cat CHANGELOG.md \| less` |
| **FIRMWARE** | `cat ESP32_Temp_Control_Valves_BT.ino \| less` |

---

## 📋 ESTRUCTURA DEL PROYECTO

```
ESP32-WROM32-CONTROL_TEMP_VALVULE/
├── 📄 Código Fuente
│   ├── ESP32_Temp_Control_Valves_BT.ino (18 KB) - Firmware v2.0.0
│   ├── lib_main.dart (14 KB) - App Flutter
│   └── pubspec.yaml - Dependencias
│
├── 📚 Documentación
│   ├── README.md (5.2 KB) - Descripción general
│   ├── CHANGELOG.md (9.3 KB) - Cambios detallados
│   ├── BOM.md (12 KB) - Lista de materiales
│   ├── SHOPPING_LIST.md (7.8 KB) - Lista de compra
│   ├── WIRING_DIAGRAM.md (37 KB) - Diagrama conexiones
│   └── QUICK_ACCESS.md - Esta guía
│
├── 🖼️ Recursos
│   ├── diagram_valves.pdf (24 KB)
│   ├── screen_*.png (3 archivos)
│   └── app_icon_tecnoworldfuture.png (123 KB)
│
└── 🔧 Utilidades
    └── open_docs.sh - Script acceso rápido
```

---

## 🔍 COMANDOS ÚTILES

### Navegar al Proyecto
```bash
cd /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
```

### Listar Archivos
```bash
ls -lh
```

### Buscar en Archivos
```bash
grep -r "texto_a_buscar" .
```

### Ver Estadísticas
```bash
# Contar líneas de documentación
wc -l *.md

# Tamaño total
du -sh .
```

### Copiar a Otra Ubicación
```bash
# A escritorio
cp -r . ~/Desktop/ESP32_Project/

# A documentos
cp *.md ~/Documents/
```

---

## 🌐 ENLACES DIRECTOS GITHUB

### Branch Actual
```
claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk
```

### URLs de Archivos
- **README**: [Ver en GitHub](https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/blob/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk/README.md)
- **BOM**: [Ver en GitHub](https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/blob/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk/BOM.md)
- **SHOPPING_LIST**: [Ver en GitHub](https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/blob/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk/SHOPPING_LIST.md)
- **WIRING_DIAGRAM**: [Ver en GitHub](https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/blob/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk/WIRING_DIAGRAM.md)
- **CHANGELOG**: [Ver en GitHub](https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE/blob/claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk/CHANGELOG.md)

---

## 📱 COMPARTIR ARCHIVOS

### Comprimir Proyecto
```bash
# Crear archivo ZIP
cd /home/user/
zip -r ESP32_Project.zip ESP32-WROM32-CONTROL_TEMP_VALVULE/

# Crear archivo TAR.GZ
tar -czf ESP32_Project.tar.gz ESP32-WROM32-CONTROL_TEMP_VALVULE/
```

### Solo Documentación
```bash
cd /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
zip ESP32_Docs.zip *.md *.ino
```

---

## 💡 TIPS RÁPIDOS

### Editar Archivos
```bash
# Con nano (fácil)
nano BOM.md

# Con vim
vim BOM.md

# Con VS Code
code BOM.md
```

### Ver Archivos sin Editar
```bash
# Ver completo
cat BOM.md

# Ver con paginación
less BOM.md

# Ver primeras líneas
head -50 BOM.md

# Ver últimas líneas
tail -50 BOM.md
```

### Imprimir Documentos
```bash
# Convertir Markdown a PDF
pandoc BOM.md -o BOM.pdf
pandoc SHOPPING_LIST.md -o SHOPPING_LIST.pdf
pandoc WIRING_DIAGRAM.md -o WIRING_DIAGRAM.pdf
```

---

## ✅ CHECKLIST DE USO

```
[ ] He navegado a /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE/
[ ] He ejecutado ./open_docs.sh
[ ] He leído README.md
[ ] He revisado BOM.md para componentes
[ ] He impreso SHOPPING_LIST.md
[ ] He estudiado WIRING_DIAGRAM.md
[ ] He abierto el firmware .ino
[ ] He visto el repositorio en GitHub
```

---

## 🆘 PROBLEMAS COMUNES

### "Permission denied" al ejecutar script
```bash
chmod +x open_docs.sh
```

### No encuentro los archivos
```bash
# Verificar que estás en el directorio correcto
pwd

# Debe mostrar:
# /home/user/ESP32-WROM32-CONTROL_TEMP_VALVULE
```

### Quiero editar pero no tengo permisos
```bash
# Cambiar permisos de lectura/escritura
chmod 644 *.md *.ino
```

---

## 📞 SOPORTE

**Repositorio:** https://github.com/twfsapack/ESP32-WROM32-CONTROL_TEMP_VALVULE

**Branch actual:** `claude/temperature-control-system-011CUdWREfQdDgf89azy2vWk`

**Versión:** 2.0.0

**Última actualización:** 2025-10-30

---

**¡Disfruta construyendo tu sistema de control ESP32!** 🚀
