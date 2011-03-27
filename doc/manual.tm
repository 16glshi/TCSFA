<TeXmacs|1.0.7.9>

<style|article>

<\body>
  <doc-data|<doc-title|Manual for <name|TCSFA>
  Package>|<doc-author-data|<author-name|Timy>>>

  <subsubsection|Form of the Light Field>

  Dipole approximation is employed. The light field is defined by its vector
  potential with the <math|sin<rsup|2>>-envolope:

  <\equation*>
    \<b-A\>\<cdot\><wide|\<b-z\>|^>=-<frac|E<rsub|0>|\<omega\><sqrt|1+\<xi\><rsup|2>>>
    sin<rsup|2><around*|(|<frac|\<omega\> t|2 N>|)> sin<around*|(|\<omega\>
    t|)>
  </equation*>

  <\equation*>
    \<b-A\>\<cdot\><wide|\<b-x\>|^>=-<frac|E<rsub|0>
    \<xi\>|\<omega\><sqrt|1+\<xi\><rsup|2>>>
    sin<rsup|2><around*|(|<frac|\<omega\> t - \<pi\>/2|2 N>|)>
    cos<around*|(|\<omega\> t|)>.
  </equation*>

  When <math|\<xi\>=0>, it describes the linearly polarized field with the
  polarization direction along the <math|z>-axis.\ 

  <subsection|Organization of the TCSFA Package>

  \;

  <\itemize>
    <item><verbatim|src>

    <\itemize>
      <item><verbatim|ccsfa>: The main part of the source of the TCSFA
      package

      <\itemize>
        <item><verbatim|core>: \ the core part of the <name|TCSFA>

        <item><verbatim|include>: stores head files generated by the Python
        script ``config.py''.

        <item><verbatim|p_entry>: entry point of the parallel version.

        <item><verbatim|s_entry>: entry point of the standalone version.

        <\itemize>
          <item><verbatim|main.f90>: is the entry point of standalone
          computation. One can modify this file to calculate a single
          trajectory or multiple trajectories and related quantities, or
          whatever.\ 

          <item><verbatim|data_proc.f90>: is used to reproduce a batch of
          trajectories selected from the raw data with certain criteria.
          Given a subset of the raw data <verbatim|select.dat> and filtering
          critera, it generates the index of the data satisfying the critera
          <verbatim|filter.dat> and the corresponding transition amplitude
          <verbatim|traj_m.dat>.
        </itemize>

        <item><verbatim|config.py>: translates parameter list into individual
        head file for each module.
      </itemize>

      <item><verbatim|mmff>: MPI Framework for Fortran
    </itemize>

    <item>ana

    <\itemize>
      <item><verbatim|proc>: post-process programs for analysis of the
      generated raw data
    </itemize>
  </itemize>

  \;
</body>

<\initial>
  <\collection>
    <associate|page-type|letter>
  </collection>
</initial>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|1|?>>
  </collection>
</references>