defmodule Servidor do
  @spec start(integer()) :: {:ok, pid()}
  def start(n) do
    workers =
    Enum.reduce(1..n, [], fn _, acc ->
      h = spawn(fn -> fworker() end)
      [h | acc]
    end)
    {:ok, spawn(fn ->fserver(workers, [], 0) end)}
  end
  @spec run_batch(pid(), list()) :: list()
  def run_batch(server, trabajos) do
    send(server, {:trabajos, self(), trabajos})
    receive do
      {:ok, results}-> results
    end
  end
  @spec stop(pid()) :: :ok
  def stop(server) do
    send(server, {:stop, self()})
    receive do
      :ok ->:ok
    end
  end
  #--- Trabajadores ---
  defp fworker() do
    receive do
      {:trabajo, from, func, id_job} ->
        result =  func.()
        send(from, {:result, self(), result, id_job})
        fworker()
      :stop-> :ok
    end
  end
  #--- Servidor ---
  defp fserver(workers, jobs_list, last_job) do
    # workers: lista de pids de trabajadores ordenada en funcion de cual fue el último en ser llamado
    #jobs_list = [(id, pid_from, job_length, completed_tasks, [workers]), job2, job3]
    # last_job: entero que sirve para asignar un identificador a cada trabajo
    receive do
      {:trabajos, from, trabajos} ->
        {workers, job_workers} = assign_job(workers, trabajos, last_job)
        job = {last_job, from, length(trabajos), 0, job_workers}
        fserver(workers, [job | jobs_list], last_job + 1)
      {:result, from, result, id_job}->
        {{pid_from, job_length, completed_tasks, assigments}, remaining_jobs} = job_locator(id_job, jobs_list)
        #Intercambia en la lista de asignaciones su pid por el resultado obtenido manteniendo el orden
        updated_assigments = assigment_swapper(from, result, assigments)
        completed_tasks = completed_tasks+1
        if job_length == completed_tasks do
          send(pid_from,{:ok, updated_assigments})
          fserver(workers, remaining_jobs, last_job)
        else
          job ={id_job, pid_from, job_length, completed_tasks, updated_assigments}
          fserver(workers, [job| remaining_jobs], last_job)
        end
      {:stop, from} ->
        Enum.each(workers, fn pid -> send(pid, :stop) end)
        send(from, :ok)
    end
  end
  #--- Funciones Auxiliares ---
  defp assign_job(workers, job_tasks, id) do
    # Asigna a cada trabajador una tarea del trabajo y devuelve la lista de workers actualizada y una lista con que las tareas de cada worker ordenadas
    # (workers, assigned_workers)
    aux_assign_job(workers, [], job_tasks, [], id)
  end
  defp aux_assign_job(workers, aux_workers, [], assigned_workers, _) do
    {workers ++ Enum.reverse(aux_workers), Enum.reverse(assigned_workers)}
  end
  defp aux_assign_job([], aux_workers, job_tasks, assigned_workers, id) do
    aux_assign_job(Enum.reverse(aux_workers), [], job_tasks, assigned_workers, id)
  end
  defp aux_assign_job([worker|tailworkers], aux_workers, [task|tailjob], assigned_workers, id) do
    send(worker, {:trabajo, self(), task, id})
    aux_assign_job(tailworkers, [worker|aux_workers], tailjob, [worker|assigned_workers], id)
  end
  defp job_locator(id_job, jobs_list) do
    # Devuelve los datos del trabajo al que está asociado un id y la lista de trabajos sin ese trabajo en su interior
    aux_job_locator(id_job, jobs_list, [])
  end
  defp aux_job_locator(id_job, [{id_job, pid_from, job_length, completed_tasks, assigments}|t], seen_jobs) do
    {{pid_from, job_length, completed_tasks, assigments},seen_jobs ++ t}
  end
  defp aux_job_locator(id, [h|t], seen_jobs) do
    aux_job_locator(id, t, [h|seen_jobs])
  end

  defp assigment_swapper(pid, result, assigments) do
    #Intercambia en la lista de asignaciones su pid por el resultado obtenido manteniendo el orden. Devuelve assigments actualizada
    aux_assigment_swapper(pid, result, assigments, [])
  end
  defp aux_assigment_swapper(pid, result, [pid | assignments], checked_assignments) do
    Enum.reverse(checked_assignments) ++ [result | assignments]
  end
  defp aux_assigment_swapper(pid, result, [h|t], checked_assigments) do
    aux_assigment_swapper(pid, result, t , [h|checked_assigments])
  end
end
