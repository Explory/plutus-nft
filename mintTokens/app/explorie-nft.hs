import           Prelude
import           System.Environment
import           Cardano.Api       hiding (TxId)
-- import           Cardano.Api.Shelley
-- import qualified Cardano.Ledger.Alonzo.Data as Alonzo
import qualified Plutus.V1.Ledger.Api as Plutus
import qualified Data.ByteString.Short as SBS
import Data.String                         (IsString (..))
import Ledger
import Ledger.Bytes                        (getLedgerBytes)

import Explorie.Minting.MintNFT

main :: IO ()
main = do
    [utxo'] <- getArgs
    let utxo            = parseUTxO utxo'
        nftPolicyFile   = "../plutus-scripts/mint-nft-policy.plutus"

    nftPolicyResult <- writeFileTextEnvelope nftPolicyFile Nothing $ apiNFTMintScript utxo
    case nftPolicyResult of
        Left err -> print $ displayError err
        Right () -> putStrLn $ "wrote NFT policy to file " ++ nftPolicyFile

parseUTxO :: String -> TxOutRef
parseUTxO s =
  let
    (x, y) = span (/= '#') s
  in
    TxOutRef (TxId $ getLedgerBytes $ fromString x) $ read $ tail y