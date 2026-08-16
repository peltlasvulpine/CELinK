# CELinK

A library to connect your TI-84 Plus CE / TI-83 Premium CE to the interwebs!
Still a work in progress.

## Checklist

### 🎯 Core goal

- [x] Give the TI-84 Plus CE internet/networking capability
- [x] Use an external device to provide networking
- [x] CE ↔ external device over USB
- [ ] External device ↔ Wi-Fi/network
- [ ] Expose all of this through a clean C library
- [ ] Eventually make it practical for normal CE users

---

## 🧱 Current architecture

```text
TI-84 Plus CE
      │
      │ USB
      ▼
   CELinK
      │
      ▼
    ESP32
      │
      │ Wi-Fi
      ▼
  Internet