defmodule Eratostenes do
  #En la versión concurrente, se implementará según el diagrama propuesto en clase.
  #Debido a la ligereza de los procesos en Elixir, generaremos tantos procesos como filtros queramos aplicar, usando un
  #pipe and filter. Cada filtro hará una comprobación de la divisibilidad por el número que contenga. Empezamos por un proceso "ultimo" que agrega todos
  #los numeros que le lleguen en una lista. Cuando le llega un nuevo número, que será primo, entonces
    #Guarda el número que le llega en su interior
    #Genera un proceso nuevo que pasa a ser el último, del que se guarda una referencia.
    #Le pasa la lista de números primos conocidos hasta el momento
  #Como optimización sencilla empezamos la lista desde 2 hasta n y le quitamos los impares.

  #Este módulo contiene cuatro definiciones, que suponen dos funciones sobrecargadas
  #Por una parte, primos(n) crea una lista de 2 a n y la pasa a criba.

  def lista_optimizada(n) do
   [2 | Enum.filter(Enum.to_list(2..n), fn x -> rem(x, 2) != 0 end)]
  end

  # def filtro(mi_primo, mi_siguiente, mi_lista_primos) do
  #receive do
  #  {:number, number} ->
  #   if mi_primo == nil do
  #    mi_primo_nuevo = number mi_siguiente = spawn(Eratostenes, filtro,[nil, nil, [mi_lista_primos]])
  #    filtro(mi_primo_nuevo, mi_siguiente_nuevo, mi_lista_primos)
  #      else
  #   if (rem(number,mi_primo) != 0) do
  #    send(mi_siguiente, {:number, number})
  #   end
  #  end
  #  {:stop} ->
  #    send(mi_siguiente,{:final})
  #    :ok
  #end
  def pp(what_to_print, debug_message \\ "") do
    IO.puts("#{IO.ANSI.yellow()} START #{debug_message} ====================")
    IO.puts(IO.ANSI.yellow() <> inspect(what_to_print, pretty: true, limit: :infinity))
    IO.puts("#{IO.ANSI.yellow()} END   #{debug_message} ====================\n\n")
    what_to_print
  end

  #Ahora mismo el código tiene un problema: nos estamos saltando algunos primos. Es probable que esto se deba a que no agregamos
  def filtro(mi_primo, mi_siguiente, mi_lista_primos) do
    #IO.inspect({self(),DateTime.utc_now(), mi_primo, mi_siguiente, [number | mi_lista_primos]}, label: "@START")
    receive do
      {:number, number} ->
        if mi_primo == nil do
          mi_primo = number

          filtro(mi_primo, mi_siguiente, [number|mi_lista_primos])
        else if rem(number, mi_primo) != 0 do
            #pass to the next filter

            #if there is no next one, it must mean that this is the last one, and we spawn a new one with the number passed which is going to be our last.
            #We also send our current primes list since we want to have them in the last one.
            if mi_siguiente == nil do
              mi_siguiente = spawn(fn -> filtro(number, nil, [number|mi_lista_primos]) end)
              IO.inspect({self(),DateTime.utc_now(),  mi_primo, mi_siguiente,  [number|mi_lista_primos]}, label: "SIGUIENTE AÑADIDO")
              filtro(mi_primo,mi_siguiente,[number|mi_lista_primos])
            else
              send(mi_siguiente, {:number, number})
              filtro(mi_primo, mi_siguiente, [number | mi_lista_primos])
            end
          else
            filtro(mi_primo, mi_siguiente, [number | mi_lista_primos])
          end
        end
      :stop -> :ok
    end
  end

  def primos(n) when n>1 do
    next = spawn(fn -> filtro(nil,nil,[]) end)
    Enum.map(lista_optimizada(n), fn x -> send(next, {:number, x}) end)
    send(next, :stop)
  end

  ## Devuelve la lista vacía
  def primos(_) do
    []
  end

  #Da la vuelta a la lista final de criba cuando le llega la lista inicial vacía.
  def criba([],_,_, lista) do
    Enum.reverse(lista)
  end

  #Criba filtra los números que sean
  #Lo mete en listafinal hasta que la lista de entrada sea vacía,
  #que es cuando entra en la otra función criba() y le da la vuelta a listafinal.
  def criba(lista,primo,n, listafinal)  do
    [h|t] = Enum.filter(lista, fn x -> rem(x, primo) != 0 or x == primo end)
    criba(t,h,n, [h|listafinal])
  end

end
