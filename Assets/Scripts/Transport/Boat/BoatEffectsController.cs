using UnityEngine;
using System.Collections.Generic;

public class BoatEffectsController : MonoBehaviour
{

    [SerializeField] public ParticleSystem ps;
    private ParticleSystem.MainModule main;
    [SerializeField] public List<TrailRenderer> trailRenderers = new List<TrailRenderer>();

    public bool isMoving = false;
    public bool activeWakeTrails = false;
    

    [SerializeField] private Rigidbody rb;


    private void Awake()
    {
        rb = GetComponent<Rigidbody>();

        if (ps != null)
        {
            main = ps.main;
        }
       // trailRenderers.Add(gameObject.GetComponentInChildren<TrailRenderer>());



    }
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {


        
    }

    // Update is called once per frame
    void Update()
    {
        ScaleWake(rb);
        
    }

    public void StartWake()
    {
        if (isMoving)
        {
            return;
        }

        isMoving = true;
        activeWakeTrails = true;

    }

    private void EnableWakeTrails()
    {
        if (!activeWakeTrails || !isMoving)
        {
            return;
        }

        if (trailRenderers.Count == 0)
        {
            return ;
        }

       foreach (var trail in trailRenderers)
        {
            trail.enabled = true;
            trail.emitting = true;
        }

       ps.gameObject.SetActive(true); //setting ps object to active.
       
       
    }

    private void EndWakeTrails() //Function ends the rendering of the wake trails and deactivates the trail renderers.
    {

        if (trailRenderers.Count == 0)
        {
            return;
        }


        foreach (var trail in trailRenderers)
        {
            trail.emitting = false;
            trail.enabled = false;
        }

        ps.gameObject.SetActive(false);
    }

    public void StopWake()
    {
        //isMoving = false;
        activeWakeTrails=false;
    }

    private void ScaleWake(Rigidbody rb)
    {

        if (!isMoving)
        {
            return;
        }


        if (rb == null)
        {
            return;
        }


        switch (rb.linearVelocity.magnitude) //Switch statement which checks the speed of the boat to alter the particles and wake.
        {
            case < 2f:
                main.startLifetime = .25f;
                EndTrailEmitting();
                break;
            case < 4f:
                main.startLifetime = .5f;
                EmitTrails();
                break;
            case < 8f:
                main.startLifetime = 2f;
                //ScaleWakeTrails(0.75f);
                break;

        }


    }

    private void ScaleWakeTrails(float trailTime)
    {
        foreach (var trail in trailRenderers)
        {
            trail.time = trailTime;
        }
    }

    private void EndTrailEmitting()
    {
        foreach (var trail in trailRenderers)
        {
            trail.emitting=false;
        }
    }

    private void EmitTrails()
    {

        foreach (var trail in trailRenderers)
        {
            trail.emitting = true;
        }
    }



}
