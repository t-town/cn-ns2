
main = do    
    file1 <- readFile "data1.dat"
    file2 <- readFile "data2.dat"
    file3 <- readFile "data3.dat"
    let x = combine file1 file2 file3
    writeFile "output.dat" (x ++ "\n")

combine :: String -> String -> String -> String
combine a b c =
    let al = lines a
        bl = lines b
        cl = lines c
    in
    concat $ map combineLines [(al !! i, bl !! i, cl !! i)| i <- [0.. ((length al)-1)]]

combineLines :: (String, String, String) -> String
combineLines (a, b, c) =
    let ax = read ((words a) !! 1) :: Int
        bx = read ((words b) !! 1) :: Int
        cx = read ((words c) !! 1) :: Int
    in
    ((words a) !! 0) ++ " " ++ (show (ax+bx+cx)) ++ "\n"
