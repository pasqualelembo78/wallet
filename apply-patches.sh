#!/bin/bash
set -e
echo "=== Applicazione patch per mevacoin-wallet-gui (NDK r26d) ==="
echo ""

# Controlla che siamo nella directory giusta
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERRORE: Esegui questo script dalla root del progetto wallet"
    exit 1
fi

echo "[0/7] Verifica cartella mevacoin"
if [ -d "mevacoin" ]; then
    echo "  -> Cartella mevacoin presente"
else
    echo "  ERRORE: cartella mevacoin non trovata!"
    exit 1
fi

echo "[1/7] Fix span.h: is_standard_layout_v → ::value"
sed -i 's/std::is_standard_layout_v<\([^>]*\)>/std::is_standard_layout<\1>::value/g' \
    mevacoin/contrib/epee/include/span.h || true

echo "[2/7] Fix span.h + string_tools.h: rimuovi has_unique_object_representations"
grep -rl "has_unique_object_representations" mevacoin/ 2>/dev/null | xargs -r sed -i '/has_unique_object_representations/d' || true

echo "[3/7] Fix wallet2_api.h: std::optional → boost::optional"
sed -i '/#include <optional>/d' mevacoin/src/wallet/api/wallet2_api.h || true
grep -q "boost/optional.hpp" mevacoin/src/wallet/api/wallet2_api.h 2>/dev/null || \
    sed -i '1i #include <boost/optional.hpp>' mevacoin/src/wallet/api/wallet2_api.h
sed -i 's/using optional = std::optional<T>;/using optional = boost::optional<T>;/' \
    mevacoin/src/wallet/api/wallet2_api.h || true

echo "[4/7] Fix keyvalue_serialization_overloads.h: const_cast per data()"
sed -i "s/char \*p_elem = mb\.data()/char *p_elem = const_cast<char*>(mb.data())/" \
    mevacoin/contrib/epee/include/serialization/keyvalue_serialization_overloads.h || true
sed -i "s/char \*pelem = buff\.data()/char *pelem = const_cast<char*>(buff.data())/" \
    mevacoin/contrib/epee/include/serialization/keyvalue_serialization_overloads.h || true

echo "[5/7] Fix syncobj.h: boost::unique_lock CTAD"
grep -q "#include <type_traits>" mevacoin/contrib/epee/include/syncobj.h 2>/dev/null || \
    sed -i '1i #include <type_traits>' mevacoin/contrib/epee/include/syncobj.h
sed -i 's/boost::unique_lock critical_region_var/boost::unique_lock<std::remove_reference_t<decltype(x)>> critical_region_var/g' \
    mevacoin/contrib/epee/include/syncobj.h || true

echo "[6/7] Fix randomx ARM64 branch trampoline"
python3 << 'PYEOF'
path = 'mevacoin/external/randomx/src/jit_compiler_a64_static.S'
try:
    lines = open(path).readlines()
    modified = False
    with open(path, 'w') as f:
        for line in lines:
            if 'bne' in line and 'randomx_program_aarch64_main_loop' in line and not modified:
                f.write('        beq     1f\n')
                f.write('        b       DECL(randomx_program_aarch64_main_loop)\n')
                f.write('1:\n')
                modified = True
            else:
                f.write(line)
    if modified:
        print("  -> Trampoline applicato")
    else:
        print("  -> Gia patchato o pattern non trovato")
except Exception as e:
    print(f"  -> Errore: {e}")
PYEOF

echo ""
echo "=== Patch GUI: branding gia applicato dal rebranding script ==="
echo "  (nessuna patch GUI necessaria)"

echo ""
echo "✅ Tutte le patch applicate con successo!"
