#!/usr/bin/env bash
# Mac ပေါ်မှာ frontend / backend SSH key ဖန်တီးပြီး AWS Secrets Manager ထဲ ထည့်ပေးတဲ့ script
# သုံးနည်း:  bash scripts/create-ssh-keys.sh
set -euo pipefail

REGION="eu-west-1"
PREFIX="vcs-workflow"              # variables.tf ထဲက secret_prefix နဲ့ တူရမယ်
KEY_DIR="$HOME/.ssh/vcs-workflow"  # repo အပြင်ဘက်မှာ သိမ်းတယ်

mkdir -p "$KEY_DIR" && chmod 700 "$KEY_DIR"

put_secret () {  # $1 = secret name, $2 = file
  if aws secretsmanager describe-secret --secret-id "$1" --region "$REGION" >/dev/null 2>&1; then
    aws secretsmanager put-secret-value --secret-id "$1" \
      --secret-string "file://$2" --region "$REGION" >/dev/null
    echo "  updated : $1"
  else
    aws secretsmanager create-secret --name "$1" \
      --secret-string "file://$2" --region "$REGION" \
      --tags Key=Project,Value=aws-vpc-peering-vcs >/dev/null
    echo "  created : $1"
  fi
}

for TIER in frontend backend; do
  KEY="$KEY_DIR/${TIER}-ssh-key"
  if [ ! -f "$KEY" ]; then
    # -N "" = passphrase မထားဘူး (HCP runner က passphrase ရိုက်ပေးလို့မရလို့)
    ssh-keygen -t ed25519 -N "" -C "${TIER}@vcs-workflow" -f "$KEY"
  fi
  chmod 400 "$KEY"

  echo "[$TIER]"
  put_secret "$PREFIX/$TIER/ssh-private-key" "$KEY"
  put_secret "$PREFIX/$TIER/ssh-public-key"  "$KEY.pub"
done

echo
aws secretsmanager list-secrets --region "$REGION" \
  --filters Key=name,Values="$PREFIX/" --query 'SecretList[].Name' --output table
