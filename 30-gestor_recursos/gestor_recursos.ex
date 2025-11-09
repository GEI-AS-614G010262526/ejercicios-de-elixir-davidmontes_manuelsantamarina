#Requisitos
#En el momento de iniciar el servidor, se le proporciona la lista de recursos disponibles inicialmente
#Los recursos se asignan en un orden arbitrario
#Para facilitar el envío de mensajes al servidor, el proceso se registra con el nombre "gestor"
#El módulo ofrece una función "start/1" que inicia el gestor y lo registra con el nombre especificado
#El módulo ofrece a los clientes un API con las funciones alloc/0, "release/1", "avail/0", que encapsulan la
#interacción con el servidor
#El gestor debe comprobar que el proceso que devuelve un recurso es el que, efectivamente, reservó el recurso
#Un cliente puede reservar más de un recurso.

#Versión no distribuida
#Versión distribuida
#Versión tolerante a fallos
defmodule GestorRecursos do
  @impl
  def alloc() do #alloc/0
    send(resource_manager, {:alloc, self()})
  end

  @impl
  def release(resource) do #release/1
    send(resource_manager, {:release, from, resource})
    receive do
      {:message_type, value} ->
        # code
    end
  end

  def avail() do #avail/0
    send(resource_manager, {:avail, self()})
  end
  def manage(available_resources,allocated_resources,available_clients,assigned_client) do
    manage(available_resources,allocated_resources,available_clients,assigned_client)
  end

  def start(available_resources) do #start/1
    #process registry
    Process.register(self(), :gestor)

    #mantaining state of:
    #resources
      # -available_resources
      # -allocated_resources
    #clients
      # -available_clients
      # -assigned_client
    manage()
    receive do
      #Una vez asignado, el recurso deja de estar disponible y no se puede asignar a ningún otro cliente hasta que sea liberado.
      #resource allocation
      {:alloc, from} ->
        #quitamos de la lista de available resources, ponemos en lista de assigned
        match Enum.count(available_resources) do

        end
        #allocation successful
        {:ok, recurso}
        #if allocation unsuccessful
        #if(Enum.count(available_resources) == 0){
          #allocation was unsuccessful, reassign
        #}

      {:avail, from} -> send(from, available_resources)
      #libera un recurso previamente asignado al cliente. Devuelve a "from"
      {:release, from, recurso} ->

      #Si la operación se lleva a cabo con éxito y el recurso queda disponible para nuevas asignaciones
      #return {:ok}
      #Si el recurso no había sido asignado al proceso "from"
      #return { :error, :recurso_no_reservado} ->
      #Devuelve el número de recursos disponibles en el servidor


    end

  end
end
