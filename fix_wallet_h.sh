#!/bin/bash
set -e
echo "Fixing Wallet.h..."

python3 - <<'ENDPY'
import os
path = os.path.expanduser("~/wallet/src/libwalletqt/Wallet.h")
with open(path, "r") as f:
    lines = f.readlines()

# Remove any broken insertions from previous sed
cleaned = [l for l in lines if "documentHashTransactionCreated" not in l
           and "createDocumentHashTransactionAsync" not in l
           and "createDocumentHashTransaction" not in l]

# Now insert correctly
result = []
for i, line in enumerate(cleaned):
    result.append(line)
    # Add Q_INVOKABLE after createSweepUnmixableTransactionAsync line
    if "createSweepUnmixableTransactionAsync" in line and "Q_INVOKABLE" in line:
        result.append("\n")
        result.append("    //! Create document hash timestamping transaction\n")
        result.append("    Q_INVOKABLE void createDocumentHashTransactionAsync(const QString &documentHash);\n")
    # Add signal after transactionCreated signal block (after the closing ;)
    if "quint32 mixinCount);" in line:
        result.append("\n")
        result.append("    void documentHashTransactionCreated(PendingTransaction *transaction, const QString &documentHash);\n")

with open(path, "w") as f:
    f.writelines(result)
print("[DONE] Wallet.h fixed")
ENDPY

echo "Rebuilding..."
cd ~/wallet
make
