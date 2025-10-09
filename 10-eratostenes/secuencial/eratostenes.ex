defmodule Eratostenes do
  def primos(n) when n>1 do
    [h|t] = Enum.to_list(2..n)
    criba(t,h,n,[])
  end
  def primos(_) do
    []
  end
  def criba([],_,_, lista) do
    Enum.reverse(lista)
  end
  def criba(lista,primo,n, listafinal)  do
    [h|t] = Enum.filter(lista, fn x -> rem(x, primo) != 0 or x == primo end)
    criba(t,h,n, [h|listafinal])
  end
end
