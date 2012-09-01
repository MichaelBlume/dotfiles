#!/usr/bin/runhaskell
dvorak_keys = "',.pyfgcrl/=\\aoeuidhtns-;qjkxbmwvz\"<>PYFGCRL?+|AOEUIDHTNS_:QJKXBMWVZ"
qwerty_keys = "qwertyuiop[]\\asdfghjkl;'zxcvbnm,./QWERTYUIOP{}|ASDFGHJKL:\"ZXCVBNM<>?"

decode_dvorak_char :: Char -> Char
decode_dvorak_char c = helper dvorak_keys qwerty_keys where
  helper [] [] = c
  helper (dk:dks) (qk:qks) = if qk == c
    then dk
    else helper dks qks

main :: IO ()
main = interact $ map decode_dvorak_char
