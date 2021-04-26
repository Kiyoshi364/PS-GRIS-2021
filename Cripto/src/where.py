from Crypto.Util.number import inverse, long_to_bytes

def decrypt(q, h, f, g, e):
    a = (f*e) % q
    m = (a*inverse(f, g)) % g
    return m

def dot(u, v):
    return u[0] * v[0] + u[1] * v[1]

def len2(u):
    return dot(u, u)

def gauss(v1, v2):

    while (1):
        if (len2(v2) < len2(v1)):
            tmp = v1
            v1 = v2
            v2 = tmp

        m = dot(v1, v2) // len2(v1)

        if (m == 0):
            break

        v2[0], v2[1] = v2[0] - m * v1[0], v2[1] - m * v1[1]

    return v1, v2

def main():

    pub_x = 7638232120454925879231554234011842347641017888219021175304217358715878636183252433454896490677496516149889316745664606749499241420160898019203925115292257
    pub_y = 2163268902194560093843693572170199707501787797497998463462129592239973581462651622978282637513865274199374452805292639586264791317439029535926401109074800
    cifra = 5605696495253720664142881956908624307570671858477482119657436163663663844731169035682344974286379049123733356009125671924280312532755241162267269123486523

    v1 = [ pub_y, 1 ]
    v2 = [ pub_x, 1 ]

    ([x1, y1], [x2, y2]) = gauss(v1, v2);

    lista = [x1, x2, y1, y2]
    for i in range(len(lista)):
        priv_y = lista[i]
        priv_x = (priv_y * inverse(pub_y, pub_x) ) % pub_x

        m = decrypt(pub_x, pub_y, priv_x, priv_y, cifra)

        mensagem = long_to_bytes(m) 

        print(i, mensagem)
    return

main()
