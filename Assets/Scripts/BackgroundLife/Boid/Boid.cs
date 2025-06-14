using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class Boids : MonoBehaviour
{

    [SerializeField] BoidManager bM;
    List<GameObject> boidsNear = new List<GameObject>();


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private Vector3 SteerSeparation()
    {
        Vector3 direction = Vector3.zero;

        var boidsInR = bM.boidList;



        return direction;

    }

   


}

