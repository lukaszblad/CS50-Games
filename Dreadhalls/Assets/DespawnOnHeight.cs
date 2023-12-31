using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour
{

    public GameObject characterController;
    public GameObject whispersSource;

    // Start is called before the first frame update
    void Start()
    {
        whispersSource = GameObject.FindGameObjectWithTag("Finish");
    }

    // Update is called once per frame
    void Update()
    {
        if (characterController.transform.position.y <= -2) {
            Destroy(whispersSource);
            SceneManager.LoadScene("GameOver");
        }
    }
}
