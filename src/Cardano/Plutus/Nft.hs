{-# LANGUAGE NoImplicitPrelude #-}
module Cardano.Plutus.Nft (
  nftMint
  ) where

import           Cardano.Api.Shelley      (PlutusScript (..), PlutusScriptV1)
import           Codec.Serialise
import qualified Data.ByteString.Lazy     as LB
import qualified Data.ByteString.Short    as SBS
import           Ledger                   hiding (singleton)
import qualified Ledger.Typed.Scripts     as Scripts
import           Ledger.Value             as Value
import qualified PlutusTx
import           PlutusTx.Prelude         hiding (Semigroup (..), unless)
import qualified Prelude               as Haskell

data ExplorieParams = ExplorieParams
    { epNFT :: AssetClass
    } deriving Haskell.Show

PlutusTx.makeLift ''ExplorieParams

{-# INLINABLE mkNFTPolicy #-}
mkNFTPolicy :: TokenName -> TxOutRef -> BuiltinData -> ScriptContext -> Bool
mkNFTPolicy tn utxo _ ctx = traceIfFalse "UTxO not consumed"   hasUTxO           &&
                            traceIfFalse "wrong amount minted" checkMintedAmount
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> txInInfoOutRef i == utxo) $ txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case flattenValue (txInfoMint info) of
        [(_, tn', amt)] -> tn' == tn && amt == 1
        _               -> False


nftTokenName :: TokenName
nftTokenName = "ExplorieNFT"

nftPolicy :: TokenName -> TxOutRef -> Scripts.MintingPolicy
nftPolicy nftTokenName utxo = mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \tn utxo' -> Scripts.wrapMintingPolicy $ mkNFTPolicy tn utxo' ||])
    `PlutusTx.applyCode`
     PlutusTx.liftCode nftTokenName
    `PlutusTx.applyCode`
     PlutusTx.liftCode utxo

nftPlutusScript :: TokenName ->  TxOutRef -> Script
nftPlutusScript nftTokenName = unMintingPolicyScript . nftPolicy nftTokenName

nftValidator :: TokenName -> TxOutRef -> Validator
nftValidator nftTokenName = Validator . nftPlutusScript nftTokenName

nftScriptAsCbor :: TokenName -> TxOutRef -> LB.ByteString
nftScriptAsCbor nftTokenName = serialise . nftValidator nftTokenName

nftMint :: TokenName -> TxOutRef -> PlutusScript PlutusScriptV1
nftMint nftTokenName
  = PlutusScriptSerialised
  . SBS.toShort
  . LB.toStrict
  . nftScriptAsCbor nftTokenName

mkExplorieValidator :: ExplorieParams -> BuiltinData -> BuiltinData -> ScriptContext -> Bool
mkExplorieValidator ep _ _ ctx =
    traceIfFalse "NFT missing from input"  (oldNFT   == 1)              &&
    traceIfFalse "NFT missing from output" (newNFT   == 1)              
  where
    ownInput :: TxOut
    ownInput = case findOwnInput ctx of
        Nothing -> traceError "explorie input missing"
        Just i  -> txInInfoResolved i

    ownOutput :: TxOut
    ownOutput = case getContinuingOutputs ctx of
        [o] -> o
        _   -> traceError "expected exactly one explorie output"

    inVal, outVal :: Value
    inVal = txOutValue ownInput
    outVal = txOutValue ownOutput

    oldNFT, newNFT :: Integer
    oldNFT     = assetClassValueOf inVal  $ epNFT ep
    newNFT     = assetClassValueOf outVal $ epNFT ep
